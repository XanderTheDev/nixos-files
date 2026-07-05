#!/usr/bin/env python3

import gi
gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, GLib
import subprocess
import threading
import json
import re
import os
import shutil


# ─── Hardware Detection ───────────────────────────────────────────────────────

def detect_cpu():
    try:
        with open("/proc/cpuinfo") as f:
            info = f.read()
        if "AuthenticAMD" in info: return "amd"
        elif "GenuineIntel" in info: return "intel"
    except Exception: pass
    return "unknown"

def detect_gpus():
    try:
        lspci = subprocess.check_output(["lspci"], stderr=subprocess.DEVNULL).decode()
    except Exception:
        return []
    gpus = []
    for line in lspci.splitlines():
        lower = line.lower()
        if any(x in lower for x in ["vga", "3d controller", "display controller"]):
            if "nvidia" in lower: gpus.append("nvidia")
            elif "amd" in lower or "radeon" in lower: gpus.append("amd")
            elif "intel" in lower: gpus.append("intel")
    return list(dict.fromkeys(gpus))

def detect_gpu_bus_ids():
    """PCI bus IDs for detected GPUs, in the "PCI:bus:dev:func" (decimal)
    format NixOS's hardware.nvidia.prime.{intel,amdgpu,nvidia}BusId options
    expect. Returns e.g. {"intel": "PCI:0:2:0", "nvidia": "PCI:1:0:0"}."""
    try:
        out = subprocess.check_output(["lspci", "-D", "-nn"], stderr=subprocess.DEVNULL).decode()
    except Exception:
        return {}
    bus_ids = {}
    for line in out.splitlines():
        lower = line.lower()
        if not any(x in lower for x in ["vga compatible controller", "3d controller", "display controller"]):
            continue
        m = re.match(r'^[0-9a-fA-F]{4}:([0-9a-fA-F]{2}):([0-9a-fA-F]{2})\.(\d)', line)
        if not m:
            continue
        bus, dev, func = int(m.group(1), 16), int(m.group(2), 16), int(m.group(3))
        pci_id = f"PCI:{bus}:{dev}:{func}"
        if "nvidia" in lower:                             bus_ids["nvidia"] = pci_id
        elif "amd" in lower or "radeon" in lower:          bus_ids["amd"]    = pci_id
        elif "intel" in lower:                             bus_ids["intel"]  = pci_id
    return bus_ids

def detect_form_factor():
    try:
        result = subprocess.check_output(
            ["dmidecode", "-s", "chassis-type"], stderr=subprocess.DEVNULL
        ).decode().strip()
        if result in ["Notebook", "Laptop", "Portable", "Sub Notebook", "Convertible"]:
            return "laptop"
    except Exception: pass
    try:
        if "BAT" in subprocess.check_output(["ls", "/sys/class/power_supply"], stderr=subprocess.DEVNULL).decode():
            return "laptop"
    except Exception: pass
    return "desktop"

# Specific machines with a dedicated nixosConfiguration (host id, match strings
# against sys_vendor/product_name from DMI, case-insensitive substrings).
KNOWN_DEVICES = [
    ("laptop",   "asus",   "x509da",   "ASUS VivoBook X509DA (preconfigured)"),
    ("thinkpad", "lenovo", "p16v gen 3", "Lenovo ThinkPad P16v Gen 3 (preconfigured)"),
]

def detect_known_device():
    try:
        vendor  = open("/sys/class/dmi/id/sys_vendor").read().strip().lower()
        product = open("/sys/class/dmi/id/product_name").read().strip().lower()
    except Exception:
        return None
    for host_id, vendor_match, product_match, desc in KNOWN_DEVICES:
        if vendor_match in vendor and product_match in product:
            return host_id, desc
    return None

def suggest_profile(cpu, gpus, form_factor):
    gpu_str = "+".join(gpus) if gpus else "unknown"
    if form_factor == "laptop":
        if gpus == ["amd"]:                   return "laptop-amd",          "AMD laptop (integrated GPU)"
        elif gpus == ["intel"]:               return "laptop-intel",         "Intel laptop (integrated GPU)"
        elif set(gpus) == {"intel","nvidia"}: return "laptop-intel-nvidia", "Intel + Nvidia laptop (PRIME)"
        elif set(gpus) == {"intel","amd"}:    return "laptop-intel-amd",    "Intel + AMD laptop (PRIME)"
        elif set(gpus) == {"amd","nvidia"}:   return "laptop-amd-nvidia",   "AMD + Nvidia laptop (PRIME)"
        else:                                 return "laptop-generic",       f"Laptop (GPU: {gpu_str})"
    else:
        if gpus == ["amd"]:                   return "desktop-amd",          "AMD desktop"
        elif gpus == ["intel"]:               return "desktop-intel",        "Intel desktop"
        elif gpus == ["nvidia"]:              return "desktop-nvidia",       "Nvidia desktop"
        elif set(gpus) == {"intel","nvidia"}: return "desktop-intel-nvidia", "Intel + Nvidia desktop (PRIME)"
        elif set(gpus) == {"intel","amd"}:    return "desktop-intel-amd",    "Intel + AMD desktop (PRIME)"
        elif set(gpus) == {"amd","nvidia"}:   return "desktop-amd-nvidia",   "AMD + Nvidia desktop (PRIME)"
        else:                                 return "desktop-generic",      f"Desktop (GPU: {gpu_str})"

def get_disks():
    try:
        output = subprocess.check_output(
            ["lsblk", "-d", "-o", "NAME,SIZE,MODEL,TYPE", "--json"], stderr=subprocess.DEVNULL
        ).decode()
        data = json.loads(output)
        disks = []
        for dev in data.get("blockdevices", []):
            if dev.get("type") == "disk":
                name = dev.get("name", "")
                size = dev.get("size", "?")
                model = (dev.get("model") or "Unknown").strip()
                disks.append({"name": name, "path": f"/dev/{name}", "size": size, "model": model})
        return disks
    except Exception:
        return []

def get_hardware_info():
    cpu = detect_cpu(); gpus = detect_gpus(); form = detect_form_factor()
    known = detect_known_device()
    if known:
        profile_id, profile_desc = known
        preconfigured = True
    else:
        profile_id, profile_desc = suggest_profile(cpu, gpus, form)
        preconfigured = False
    return {"cpu": cpu, "gpus": gpus, "form_factor": form,
            "profile_id": profile_id, "profile_desc": profile_desc,
            "preconfigured": preconfigured}

def get_timezones():
    try:
        out = subprocess.check_output(["timedatectl", "list-timezones"], stderr=subprocess.DEVNULL).decode()
        return out.strip().splitlines()
    except Exception:
        return [
            "Europe/Amsterdam","Europe/London","Europe/Berlin","Europe/Paris",
            "Europe/Rome","Europe/Madrid","Europe/Brussels","Europe/Zurich",
            "America/New_York","America/Chicago","America/Denver","America/Los_Angeles",
            "America/Toronto","America/Sao_Paulo","Asia/Tokyo","Asia/Shanghai",
            "Asia/Kolkata","Asia/Dubai","Australia/Sydney","Pacific/Auckland","UTC",
        ]

KEYBOARD_LAYOUTS = [
    ("us",       ""),  "US",
    ("us",  "intl"),   "US International",
    ("gb",       ""),  "UK",
    ("de",       ""),  "German",
    ("fr",       ""),  "French",
    ("nl",       ""),  "Dutch",
    ("es",       ""),  "Spanish",
    ("it",       ""),  "Italian",
    ("pt",       ""),  "Portuguese",
    ("ru",       ""),  "Russian",
    ("jp",       ""),  "Japanese",
    ("us",  "dvorak"), "Dvorak",
    ("us", "colemak"), "Colemak",
]

KEYBOARD_LAYOUTS = [
    (("us",      ""),      "US"),
    (("us",      "intl"),  "US International"),
    (("gb",      ""),      "UK"),
    (("de",      ""),      "German"),
    (("fr",      ""),      "French"),
    (("nl",      ""),      "Dutch"),
    (("es",      ""),      "Spanish"),
    (("it",      ""),      "Italian"),
    (("pt",      ""),      "Portuguese"),
    (("ru",      ""),      "Russian"),
    (("jp",      ""),      "Japanese"),
    (("us",  "dvorak"),    "Dvorak"),
    (("us",  "colemak"),   "Colemak"),
]

CPU_OPTIONS = ["amd", "intel"]

# GPU combos valid per CPU vendor. An integrated GPU's vendor must match the
# CPU vendor (no AMD CPU + Intel iGPU, no Intel CPU + AMD iGPU), so these are
# kept separate rather than one shared list with impossible entries.
GPU_OPTIONS_BY_CPU = {
    "amd": [
        (["amd"],          "AMD only"),
        (["nvidia"],       "Nvidia only"),
        (["amd","nvidia"], "AMD + Nvidia (PRIME)"),
    ],
    "intel": [
        (["intel"],          "Intel only"),
        (["nvidia"],         "Nvidia only"),
        (["intel","nvidia"], "Intel + Nvidia (PRIME)"),
        (["intel","amd"],    "Intel + AMD (PRIME)"),
    ],
}
FORM_OPTIONS = ["laptop", "desktop"]
TEST_MODE    = False


# ─── CSS ──────────────────────────────────────────────────────────────────────

CSS = """
window { background-color: #1e1e2e; color: #cdd6f4; }
.title { font-size: 28px; font-weight: bold; color: #cba6f7; }
.subtitle { font-size: 14px; color: #a6adc8; }
.card { background-color: #313244; border-radius: 12px; padding: 16px; }
.card-title { font-size: 13px; font-weight: bold; color: #a6adc8;
              text-transform: uppercase; letter-spacing: 1px; }
.card-value { font-size: 16px; color: #cdd6f4; font-weight: bold; }
.profile-badge { background-color: #89b4fa; color: #1e1e2e; border-radius: 8px;
                 padding: 4px 12px; font-weight: bold; font-size: 13px; }
.next-button { background-color: #cba6f7; color: #1e1e2e; border-radius: 8px;
               font-weight: bold; font-size: 15px; padding: 10px 32px; }
.next-button:hover { background-color: #b4befe; }
.install-button { background-color: #a6e3a1; color: #1e1e2e; border-radius: 8px;
                  font-weight: bold; font-size: 15px; padding: 10px 32px; }
.install-button:hover { background-color: #94e2d5; }
.override-link { color: #89b4fa; font-size: 13px; background: none; border: none; padding: 0; }
.override-link:hover { color: #cba6f7; }
.warn-card { background-color: #45475a; border: 1px solid #f38ba8; }
.warn-title { font-size: 15px; font-weight: bold; color: #f38ba8; }
.section-title { font-size: 15px; font-weight: bold; color: #cdd6f4; }
.terminal { background-color: #11111b; color: #a6e3a1; border-radius: 8px;
            padding: 12px; font-family: monospace; font-size: 12px; }
.status-running { color: #89b4fa; font-size: 14px; font-weight: bold; }
.status-done    { color: #a6e3a1; font-size: 14px; font-weight: bold; }
.status-error   { color: #f38ba8; font-size: 14px; font-weight: bold; }
entry { background-color: #45475a; color: #cdd6f4; border-radius: 8px;
        border: 1px solid #585b70; padding: 8px; }
entry:focus { border-color: #cba6f7; }
.tz-dropdown-button { background-color: #45475a; color: #cdd6f4; border-radius: 8px;
                      border: 1px solid #585b70; padding: 8px 10px; font-weight: normal; }
.tz-dropdown-button:hover { border-color: #cba6f7; }
"""


# ─── Searchable dropdown widget ───────────────────────────────────────────────
#
# Built on GTK4's native Gtk.DropDown, which has its own built-in, well-tested
# search popup (enable-search). This avoids hand-rolling popover/listbox/entry
# wiring ourselves — the native widget already handles selection highlighting,
# keyboard nav, closing on select, and scrolling the selected item into view.

class SearchableList(Gtk.Box):
    """Thin wrapper around Gtk.DropDown that exposes the same small interface
    the rest of the app expects: get_selected() and connect_changed(cb)."""

    def __init__(self, items, selected=None):
        super().__init__()
        self._items = list(items)                              # real values, e.g. "America/New_York"
        self._display = [i.replace("_", " ") for i in items]    # shown/searched, e.g. "America/New York"
        self._callbacks = []

        self._model = Gtk.StringList.new(self._display)
        expression = Gtk.PropertyExpression.new(Gtk.StringObject, None, "string")

        self._dropdown = Gtk.DropDown(model=self._model, expression=expression)
        self._dropdown.set_enable_search(True)
        try:
            self._dropdown.set_search_match_mode(Gtk.StringFilterMatchMode.SUBSTRING)
        except AttributeError:
            pass  # older GTK without this property; falls back to prefix match
        self._dropdown.set_hexpand(True)
        self._dropdown.add_css_class("tz-dropdown-button")

        selected = selected or (self._items[0] if self._items else "")
        try:
            idx = self._items.index(selected)
        except ValueError:
            idx = 0
        self._dropdown.set_selected(idx)
        self._selected = self._items[idx] if self._items else ""

        self._dropdown.connect("notify::selected-item", self._on_selected_changed)
        self.append(self._dropdown)

    def _on_selected_changed(self, dropdown, _pspec):
        idx = dropdown.get_selected()
        if idx < 0 or idx >= len(self._items):
            return
        self._selected = self._items[idx]
        for cb in self._callbacks:
            cb(self._selected)

    def get_selected(self):
        return self._selected

    def connect_changed(self, cb):
        self._callbacks.append(cb)


# ─── Window ───────────────────────────────────────────────────────────────────

class XDOSInstaller(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app, title="XDOS Installer")
        self.set_default_size(700, 520)
        self.set_resizable(False)

        css = Gtk.CssProvider()
        css.load_from_data(CSS.encode())
        Gtk.StyleContext.add_provider_for_display(
            self.get_display(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.hw            = None
        self.selected_disk = None
        self.user_config   = {
            "username":   "xander",
            "timezone":   "Europe/Amsterdam",
            "kb_layout":  "us",
            "kb_variant": "intl",
        }
        self._build_welcome_page()

    def _clear(self):
        if self.get_child(): self.set_child(None)

    def _nav_row(self, back_fn=None, next_label="Continue →", next_fn=None, next_class="next-button"):
        nav = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        if back_fn:
            b = Gtk.Button(label="← Back"); b.add_css_class("next-button")
            b.connect("clicked", lambda _: back_fn())
            nav.append(b)
        sp = Gtk.Box(); sp.set_hexpand(True); nav.append(sp)
        if next_fn:
            n = Gtk.Button(label=next_label); n.add_css_class(next_class)
            n.connect("clicked", lambda _: next_fn()); nav.append(n)
        return nav

    def _page_header(self, outer, title_text, subtitle_text):
        t = Gtk.Label(label=title_text); t.add_css_class("title"); t.set_halign(Gtk.Align.START)
        outer.append(t)
        s = Gtk.Label(label=subtitle_text); s.add_css_class("subtitle"); s.set_halign(Gtk.Align.START)
        s.set_margin_top(4); s.set_margin_bottom(28)
        outer.append(s)

    def _form_row(self, grid, label_text, widget, row):
        lbl = Gtk.Label(label=label_text); lbl.add_css_class("section-title")
        lbl.set_halign(Gtk.Align.START); lbl.set_valign(Gtk.Align.START)
        lbl.set_size_request(180, -1); lbl.set_margin_top(6)
        grid.attach(lbl, 0, row, 1, 1)
        widget.set_hexpand(True)
        grid.attach(widget, 1, row, 1, 1)

    # ── Welcome ────────────────────────────────────────────────────────────

    def _build_welcome_page(self):
        self._clear()
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=24)
        box.set_margin_top(48); box.set_margin_bottom(48)
        box.set_margin_start(64); box.set_margin_end(64)
        box.set_valign(Gtk.Align.CENTER)
        t = Gtk.Label(label="Welcome to XDOS"); t.add_css_class("title"); box.append(t)
        s = Gtk.Label(label="Detecting your hardware..."); s.add_css_class("subtitle"); box.append(s)
        sp = Gtk.Spinner(); sp.set_size_request(48, 48); sp.start(); box.append(sp)
        self.set_child(box)
        threading.Thread(target=lambda: GLib.idle_add(
            self._on_hardware_detected, get_hardware_info()
        ), daemon=True).start()

    def _on_hardware_detected(self, hw):
        self.hw = hw; self._build_hardware_page()

    # ── Hardware ───────────────────────────────────────────────────────────

    def _build_hardware_page(self):
        self._clear()
        hw = self.hw
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.set_margin_top(40); outer.set_margin_bottom(40)
        outer.set_margin_start(64); outer.set_margin_end(64)
        self._page_header(outer, "XDOS Installer", "Detected hardware")

        grid = Gtk.Grid(); grid.set_column_spacing(16); grid.set_row_spacing(16)
        outer.append(grid)

        def make_card(label, value):
            card = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
            card.add_css_class("card"); card.set_hexpand(True)
            lbl = Gtk.Label(label=label); lbl.add_css_class("card-title"); lbl.set_halign(Gtk.Align.START)
            card.append(lbl)
            val = Gtk.Label(label=value); val.add_css_class("card-value"); val.set_halign(Gtk.Align.START)
            card.append(val)
            return card

        gpu_display = ", ".join(hw["gpus"]).upper() if hw["gpus"] else "Unknown"
        grid.attach(make_card("CPU", hw["cpu"].upper()), 0, 0, 1, 1)
        grid.attach(make_card("GPU", gpu_display), 1, 0, 1, 1)
        grid.attach(make_card("Form Factor", hw["form_factor"].capitalize()), 0, 1, 1, 1)

        profile_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        profile_box.add_css_class("card")
        pl = Gtk.Label(label="SUGGESTED PROFILE"); pl.add_css_class("card-title"); pl.set_halign(Gtk.Align.START)
        profile_box.append(pl)
        badge_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        badge_row.set_valign(Gtk.Align.CENTER)
        badge = Gtk.Label(label=hw["profile_id"]); badge.add_css_class("profile-badge"); badge_row.append(badge)
        desc = Gtk.Label(label=hw["profile_desc"]); desc.add_css_class("subtitle"); badge_row.append(desc)
        sp = Gtk.Box(); sp.set_hexpand(True); badge_row.append(sp)
        override_btn = Gtk.Button(label="Not correct? Override"); override_btn.add_css_class("override-link")
        override_btn.connect("clicked", lambda _: self._build_override_page())
        badge_row.append(override_btn)
        profile_box.append(badge_row)
        grid.attach(profile_box, 0, 2, 2, 1)

        spacer = Gtk.Box(); spacer.set_vexpand(True); outer.append(spacer)
        outer.append(self._nav_row(next_fn=self._build_disk_page))
        self.set_child(outer)

    # ── Override ───────────────────────────────────────────────────────────

    def _build_override_page(self):
        self._clear()
        hw = self.hw
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.set_margin_top(40); outer.set_margin_bottom(40)
        outer.set_margin_start(64); outer.set_margin_end(64)
        self._page_header(outer, "Override Hardware", "Manually select your hardware configuration.")

        top_grid = Gtk.Grid(); top_grid.set_column_spacing(24); top_grid.set_row_spacing(20)
        outer.append(top_grid)

        device_labels = ["Auto-detect (generic hardware profile)"] + [d[3] for d in KNOWN_DEVICES]
        device_model = Gtk.StringList.new(device_labels)
        device_drop = Gtk.DropDown.new(device_model, None)
        device_drop.add_css_class("tz-dropdown-button"); device_drop.set_hexpand(True)
        # index 0 = generic, index i+1 = KNOWN_DEVICES[i]
        device_idx = 0
        if hw.get("preconfigured"):
            for i, (host_id, _, _, _) in enumerate(KNOWN_DEVICES):
                if host_id == hw["profile_id"]: device_idx = i + 1; break
        device_drop.set_selected(device_idx)
        self._form_row(top_grid, "Device", device_drop, 0)

        generic_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        grid = Gtk.Grid(); grid.set_column_spacing(24); grid.set_row_spacing(20)
        grid.set_margin_top(20)
        generic_box.append(grid)
        outer.append(generic_box)

        cpu_model = Gtk.StringList.new(["AMD", "Intel"])
        cpu_drop = Gtk.DropDown.new(cpu_model, None)
        cpu_drop.add_css_class("tz-dropdown-button"); cpu_drop.set_hexpand(True)
        cpu_drop.set_selected(0 if hw["cpu"] == "amd" else 1)
        self._form_row(grid, "CPU", cpu_drop, 0)

        def gpu_options_for(cpu_key):
            return GPU_OPTIONS_BY_CPU[cpu_key]

        gpu_drop = Gtk.DropDown()
        gpu_drop.add_css_class("tz-dropdown-button"); gpu_drop.set_hexpand(True)

        def set_gpu_options(cpu_key, preferred_gpus=None):
            opts = gpu_options_for(cpu_key)
            gpu_drop.set_model(Gtk.StringList.new([label for _, label in opts]))
            idx = 0
            if preferred_gpus is not None:
                for i, (gpus, _) in enumerate(opts):
                    if set(gpus) == set(preferred_gpus): idx = i; break
            gpu_drop.set_selected(idx)
            gpu_drop._current_options = opts  # stash for apply_override()

        set_gpu_options(hw["cpu"], hw["gpus"])
        self._form_row(grid, "GPU", gpu_drop, 1)

        cpu_drop.connect("notify::selected", lambda dd, _p:
            set_gpu_options(CPU_OPTIONS[dd.get_selected()]))

        form_model = Gtk.StringList.new(["Laptop", "Desktop"])
        form_drop = Gtk.DropDown.new(form_model, None)
        form_drop.add_css_class("tz-dropdown-button"); form_drop.set_hexpand(True)
        form_drop.set_selected(0 if hw["form_factor"] == "laptop" else 1)
        self._form_row(grid, "Form Factor", form_drop, 2)

        def on_device_changed(dd, _p):
            generic_box.set_visible(dd.get_selected() == 0)
        device_drop.connect("notify::selected", on_device_changed)
        on_device_changed(device_drop, None)

        spacer = Gtk.Box(); spacer.set_vexpand(True); outer.append(spacer)

        def apply_override():
            idx = device_drop.get_selected()
            if idx > 0:
                host_id, _, _, desc = KNOWN_DEVICES[idx - 1]
                self.hw = {"cpu": hw["cpu"], "gpus": hw["gpus"], "form_factor": hw["form_factor"],
                           "profile_id": host_id, "profile_desc": desc, "preconfigured": True}
            else:
                new_cpu  = CPU_OPTIONS[cpu_drop.get_selected()]
                new_gpus = gpu_drop._current_options[gpu_drop.get_selected()][0]
                new_form = FORM_OPTIONS[form_drop.get_selected()]
                profile_id, profile_desc = suggest_profile(new_cpu, new_gpus, new_form)
                self.hw = {"cpu": new_cpu, "gpus": new_gpus, "form_factor": new_form,
                           "profile_id": profile_id, "profile_desc": profile_desc,
                           "preconfigured": False}
            self._build_hardware_page()

        outer.append(self._nav_row(back_fn=self._build_hardware_page, next_label="Apply", next_fn=apply_override))
        self.set_child(outer)

    # ── Disk selection ─────────────────────────────────────────────────────

    def _build_disk_page(self):
        self._clear()
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.set_margin_top(40); outer.set_margin_bottom(40)
        outer.set_margin_start(64); outer.set_margin_end(64)
        self._page_header(outer, "Select Disk",
                          "Choose the disk to install XDOS on. This will erase it completely.")

        disks = get_disks()
        if not disks:
            err = Gtk.Label(label="No disks found."); err.add_css_class("subtitle"); outer.append(err)
        else:
            group = None
            for disk in disks:
                row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
                row.add_css_class("card"); row.set_margin_bottom(8)
                radio = Gtk.CheckButton()
                if group is None: group = radio; self.selected_disk = disk
                else: radio.set_group(group)
                radio.set_valign(Gtk.Align.CENTER)
                info = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4); info.set_hexpand(True)
                pl = Gtk.Label(label=disk["path"]); pl.add_css_class("card-value"); pl.set_halign(Gtk.Align.START)
                dl = Gtk.Label(label=f"{disk['model']}  ·  {disk['size']}"); dl.add_css_class("subtitle"); dl.set_halign(Gtk.Align.START)
                info.append(pl); info.append(dl)
                row.append(radio); row.append(info); outer.append(row)
                def on_toggled(btn, d=disk):
                    if btn.get_active(): self.selected_disk = d
                radio.connect("toggled", on_toggled)
                if group == radio: radio.set_active(True)

        warning = Gtk.Label(label="⚠  All data on the selected disk will be permanently erased.")
        warning.add_css_class("subtitle"); warning.set_halign(Gtk.Align.START); warning.set_margin_top(16)
        outer.append(warning)
        spacer = Gtk.Box(); spacer.set_vexpand(True); outer.append(spacer)
        outer.append(self._nav_row(back_fn=self._build_hardware_page, next_fn=self._build_user_page))
        self.set_child(outer)

    # ── User setup ─────────────────────────────────────────────────────────

    def _build_user_page(self):
        self._clear()
        uc = self.user_config
        timezones = get_timezones()

        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.set_margin_top(40); outer.set_margin_bottom(40)
        outer.set_margin_start(64); outer.set_margin_end(64)
        self._page_header(outer, "User Setup", "Configure your account and system settings.")

        form = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        form.add_css_class("card"); outer.append(form)

        grid = Gtk.Grid(); grid.set_column_spacing(24); grid.set_row_spacing(16); grid.set_margin_top(4)
        form.append(grid)

        # Username
        username_entry = Gtk.Entry()
        username_entry.set_text(uc["username"])
        username_entry.set_placeholder_text("e.g. xander")
        self._form_row(grid, "Username", username_entry, 0)

        # Timezone — custom searchable list
        tz_widget = SearchableList(timezones, selected=uc["timezone"])
        self._form_row(grid, "Timezone", tz_widget, 1)

        # Keyboard layout — simple dropdown (short list, no search needed)
        kb_labels = [label for _, label in KEYBOARD_LAYOUTS]
        kb_store = Gtk.StringList.new(kb_labels)
        kb_drop = Gtk.DropDown.new(kb_store, None)
        kb_drop.add_css_class("tz-dropdown-button")
        kb_drop.set_hexpand(True)
        default_kb = (uc["kb_layout"], uc["kb_variant"])
        for i, ((layout, variant), _) in enumerate(KEYBOARD_LAYOUTS):
            if (layout, variant) == default_kb:
                kb_drop.set_selected(i); break
        self._form_row(grid, "Keyboard Layout", kb_drop, 2)

        self._user_error = Gtk.Label(label="")
        self._user_error.add_css_class("warn-title"); self._user_error.set_halign(Gtk.Align.START)
        self._user_error.set_margin_top(12)
        outer.append(self._user_error)

        spacer = Gtk.Box(); spacer.set_vexpand(True); outer.append(spacer)

        def save_and_continue():
            username = username_entry.get_text().strip()
            if not username:
                self._user_error.set_label("Username cannot be empty."); return
            if not re.match(r'^[a-z_][a-z0-9_-]*$', username):
                self._user_error.set_label("Username must be lowercase letters, numbers, _ or - only."); return
            tz = tz_widget.get_selected()
            (kb_layout, kb_variant), _ = KEYBOARD_LAYOUTS[kb_drop.get_selected()]
            self.user_config = {"username": username, "timezone": tz,
                                "kb_layout": kb_layout, "kb_variant": kb_variant}
            self._build_confirm_page()

        # Enter on username moves to timezone search
        username_entry.connect("activate", lambda _: save_and_continue())

        outer.append(self._nav_row(back_fn=self._build_disk_page, next_fn=save_and_continue))
        self.set_child(outer)

    # ── Confirmation ───────────────────────────────────────────────────────

    def _build_confirm_page(self):
        self._clear()
        hw = self.hw; disk = self.selected_disk; uc = self.user_config
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.set_margin_top(40); outer.set_margin_bottom(40)
        outer.set_margin_start(64); outer.set_margin_end(64)
        self._page_header(outer, "Confirm Installation", "Review your choices before installing.")

        summary = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        summary.add_css_class("card"); summary.set_margin_bottom(16)

        def summary_row(label, value):
            row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
            lbl = Gtk.Label(label=label); lbl.add_css_class("card-title")
            lbl.set_halign(Gtk.Align.START); lbl.set_size_request(160, -1)
            row.append(lbl)
            val = Gtk.Label(label=value); val.add_css_class("card-value"); val.set_halign(Gtk.Align.START)
            row.append(val)
            return row

        gpu_display = ", ".join(hw["gpus"]).upper() if hw["gpus"] else "Unknown"
        disk_str    = f"{disk['path']}  ({disk['model']}, {disk['size']})" if disk else "None"
        kb_str      = uc["kb_layout"] + (f" ({uc['kb_variant']})" if uc["kb_variant"] else "")

        summary.append(summary_row("Profile",     hw["profile_id"]))
        summary.append(summary_row("CPU",         hw["cpu"].upper()))
        summary.append(summary_row("GPU",         gpu_display))
        summary.append(summary_row("Target disk", disk_str))
        summary.append(summary_row("Username",    uc["username"]))
        summary.append(summary_row("Timezone",    uc["timezone"]))
        summary.append(summary_row("Keyboard",    kb_str))
        outer.append(summary)

        warn_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        warn_box.add_css_class("card"); warn_box.add_css_class("warn-card")
        wt = Gtk.Label(label="⚠  This cannot be undone"); wt.add_css_class("warn-title"); wt.set_halign(Gtk.Align.START)
        warn_box.append(wt)
        disk_path = disk["path"] if disk else "the selected disk"
        wb = Gtk.Label(label=f"All data on {disk_path} will be permanently erased.\nMake sure you have backed up anything important.")
        wb.add_css_class("subtitle"); wb.set_halign(Gtk.Align.START); wb.set_wrap(True)
        warn_box.append(wb)
        outer.append(warn_box)

        # ← Fix: margin between warning and nav buttons
        spacer = Gtk.Box(); spacer.set_vexpand(True); outer.append(spacer)

        nav_wrapper = Gtk.Box(); nav_wrapper.set_margin_top(16); nav_wrapper.set_hexpand(True)
        nav_wrapper.append(self._nav_row(
            back_fn=self._build_user_page,
            next_label="Install XDOS",
            next_fn=self._build_install_page,
            next_class="install-button"
        ))
        outer.append(nav_wrapper)
        self.set_child(outer)

    # ── Install ────────────────────────────────────────────────────────────

    def _build_install_page(self):
        self._clear()
        hw = self.hw; disk = self.selected_disk
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.set_margin_top(40); outer.set_margin_bottom(40)
        outer.set_margin_start(64); outer.set_margin_end(64)
        self._page_header(outer, "Installing XDOS", "Please wait, do not turn off your computer.")

        self._status_label = Gtk.Label(label="Starting installation...")
        self._status_label.add_css_class("status-running"); self._status_label.set_halign(Gtk.Align.START)
        self._status_label.set_margin_bottom(12); outer.append(self._status_label)

        scroll = Gtk.ScrolledWindow()
        scroll.set_vexpand(True)
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        self._terminal_buf = Gtk.TextBuffer()
        tv = Gtk.TextView.new_with_buffer(self._terminal_buf)
        tv.add_css_class("terminal"); tv.set_editable(False)
        tv.set_cursor_visible(False); tv.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
        scroll.set_child(tv); outer.append(scroll); self._scroll = scroll

        nav = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12); nav.set_margin_top(16)
        sp = Gtk.Box(); sp.set_hexpand(True); nav.append(sp)
        self._continue_btn = Gtk.Button(label="Continue →"); self._continue_btn.add_css_class("next-button")
        self._continue_btn.set_visible(False)
        self._continue_btn.connect("clicked", lambda _: self._build_password_page())
        nav.append(self._continue_btn); outer.append(nav)

        self.set_child(outer)
        threading.Thread(target=self._run_install, args=(hw, disk), daemon=True).start()

    def _append_terminal(self, text):
        end = self._terminal_buf.get_end_iter()
        self._terminal_buf.insert(end, text)
        adj = self._scroll.get_vadjustment(); adj.set_value(adj.get_upper())

    # profile_id -> (gpu keys needed from detect_gpu_bus_ids(), nix attr names)
    PRIME_BUS_ID_MAP = {
        "laptop-intel-nvidia":  {"intelBusId": "intel", "nvidiaBusId": "nvidia"},
        "desktop-intel-nvidia": {"intelBusId": "intel", "nvidiaBusId": "nvidia"},
        "laptop-amd-nvidia":    {"amdgpuBusId": "amd",  "nvidiaBusId": "nvidia"},
        "desktop-amd-nvidia":   {"amdgpuBusId": "amd",  "nvidiaBusId": "nvidia"},
        "thinkpad":             {"intelBusId": "intel", "nvidiaBusId": "nvidia"},
    }

    def _prepare_install_repo(self, username, profile_id):
      src, dest = "/iso/nixos-files", "/tmp/xdos-install/nixos-files"
      if os.path.exists(dest):
          shutil.rmtree(dest)

      # Copy but force all files/dirs to be writable (iso squashfs preserves
      # read-only permissions from the source, so we override them explicitly).
      def copy_writable(src, dst, **kwargs):
        shutil.copy2(src, dst)
        os.chmod(dst, 0o644)

      shutil.copytree(src, dest, copy_function=copy_writable)

      # Also ensure all directories are writable/executable
      for root, dirs, files in os.walk(dest):
        os.chmod(root, 0o755)
        for f in files:
            os.chmod(os.path.join(root, f), 0o644)

      with open(os.path.join(dest, "user.nix"), "w") as f:
        f.write(f'{{ username = "{username}"; }}\n')

      attr_map = self.PRIME_BUS_ID_MAP.get(profile_id)
      if attr_map:
        detected = detect_gpu_bus_ids()
        attrs = {attr: detected[gpu_key] for attr, gpu_key in attr_map.items() if gpu_key in detected}
        if attrs:
            body = "; ".join(f'{k} = "{v}"' for k, v in attrs.items())
            with open(os.path.join(dest, "prime.nix"), "w") as f:
                f.write(f'{{ {body}; }}\n')
      return dest

    def _run_install(self, hw, disk):
        def append(text): GLib.idle_add(self._append_terminal, text)
        def set_status(text, cls="status-running"):
            GLib.idle_add(lambda: (self._status_label.set_label(text), self._status_label.set_css_classes([cls])))

        if TEST_MODE:
            cmd = ["bash", "-c",
                   "echo 'Partitioning disk...' && sleep 1 && "
                   "echo 'Creating partitions...' && sleep 1 && "
                   "echo 'Formatting filesystems...' && sleep 1 && "
                   "for i in $(seq 1 5); do echo \"Installing package $i/5...\"; sleep 0.5; done && "
                   "echo 'Done!'"]
        else:
            try:
                repo = self._prepare_install_repo(self.user_config["username"], hw["profile_id"])
            except Exception as e:
                set_status("Installation failed", "status-error")
                append(f"\n✗ Failed to prepare install repo: {e}\n")
                return
            cmd = ["sudo", "disko-install",
                   "--mode", "format",
                   "--flake", f"{repo}#{hw['profile_id']}",
                   "--disk", "main", disk["path"],
                   "--write-efi-boot-entries"]

        append(f"$ {' '.join(cmd)}\n\n")
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
            for line in proc.stdout: append(line)
            proc.wait()
            if proc.returncode == 0:
                # disko-install unmounts everything on exit, remount root for password step
                disk_path = disk["path"]
                # root is the 3rd partition (after ESP and swap)
                root_partition = f"{disk_path}3" if not disk_path[-1].isdigit() else f"{disk_path}p3"
                subprocess.run(["sudo", "mount", root_partition, "/mnt"], check=False)
                # Copy nixos-files to the installed user's home
                dest_nixos = f"/mnt/home/{self.user_config['username']}/nixos-files"
                subprocess.run(["sudo", "cp", "-r", repo, dest_nixos], check=False)
                subprocess.run(["sudo", "nixos-enter", "--root", "/mnt", "--", "chown", "-R",
                    f"{self.user_config['username']}:{self.user_config['username']}",
                    f"/home/{self.user_config['username']}/nixos-files"], check=False)
                
                set_status("Installation complete!", "status-done")
                append("\n✓ Installation finished successfully.\n")
                GLib.idle_add(lambda: self._continue_btn.set_visible(True))
            else:
                set_status(f"Installation failed (exit code {proc.returncode})", "status-error")
                append(f"\n✗ Installation failed with exit code {proc.returncode}.\n")
        except Exception as e:
            set_status("Installation failed", "status-error"); append(f"\n✗ Error: {e}\n")

    # ── Password ───────────────────────────────────────────────────────────

    def _build_password_page(self):
        self._clear()
        uc = self.user_config
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.set_margin_top(40); outer.set_margin_bottom(40)
        outer.set_margin_start(64); outer.set_margin_end(64)
        self._page_header(outer, "Set Password", f"Choose a password for {uc['username']}.")

        form = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        form.add_css_class("card"); form.set_margin_bottom(16)
        grid = Gtk.Grid(); grid.set_column_spacing(24); grid.set_row_spacing(16)
        form.append(grid)

        pw_entry  = Gtk.Entry(); pw_entry.set_visibility(False);  pw_entry.set_hexpand(True)
        pw2_entry = Gtk.Entry(); pw2_entry.set_visibility(False); pw2_entry.set_hexpand(True)
        self._form_row(grid, "Password",         pw_entry,  0)
        self._form_row(grid, "Confirm password", pw2_entry, 1)
        outer.append(form)

        self._pw_error = Gtk.Label(label=""); self._pw_error.add_css_class("warn-title")
        self._pw_error.set_halign(Gtk.Align.START); outer.append(self._pw_error)

        spacer = Gtk.Box(); spacer.set_vexpand(True); outer.append(spacer)

        def set_password():
            pw = pw_entry.get_text(); pw2 = pw2_entry.get_text()
            if not pw:   self._pw_error.set_label("Password cannot be empty."); return
            if pw != pw2: self._pw_error.set_label("Passwords do not match."); return
            if TEST_MODE:
                print(f"[TEST MODE] Would set password for {uc['username']}")
                self._build_done_page(); return
            try:
                subprocess.run(
                    ["sudo", "nixos-enter", "--root", "/mnt", "--", "bash", "-c",
                     f"echo '{uc['username']}:{pw}' | chpasswd"], check=True
                )
                self._build_done_page()
            except subprocess.CalledProcessError as e:
                self._pw_error.set_label(f"Failed to set password: {e}")

        pw_entry.connect("activate",  lambda _: pw2_entry.grab_focus())
        pw2_entry.connect("activate", lambda _: set_password())

        outer.append(self._nav_row(next_label="Set Password & Finish",
                                   next_fn=set_password, next_class="install-button"))
        self.set_child(outer)

    # ── Done ───────────────────────────────────────────────────────────────

    def _build_done_page(self):
        self._clear()
        uc = self.user_config
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=24)
        box.set_margin_top(48); box.set_margin_bottom(48)
        box.set_margin_start(64); box.set_margin_end(64)
        box.set_valign(Gtk.Align.CENTER)
        t = Gtk.Label(label="Installation Complete!"); t.add_css_class("title"); box.append(t)
        s = Gtk.Label(label=f"XDOS has been installed successfully.\nYou can log in as '{uc['username']}' after rebooting.")
        s.add_css_class("subtitle"); s.set_justify(Gtk.Justification.CENTER); box.append(s)
        reboot_btn = Gtk.Button(label="Reboot now"); reboot_btn.add_css_class("install-button"); reboot_btn.set_halign(Gtk.Align.CENTER)
        if TEST_MODE:
            reboot_btn.connect("clicked", lambda _: print("[TEST MODE] Would reboot"))
        else:
            reboot_btn.connect("clicked", lambda _: subprocess.run(["reboot"]))
        box.append(reboot_btn)
        self.set_child(box)


# ─── App entry ────────────────────────────────────────────────────────────────

class XDOSApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id="nl.xdos.installer")

    def do_activate(self):
        win = XDOSInstaller(self); win.present()


if __name__ == "__main__":
    app = XDOSApp(); app.run()
