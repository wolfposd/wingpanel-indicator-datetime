/*
 * Copyright (c) 2011-2015 elementary LLC. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class DateTime.Widgets.PanelLabel : Gtk.Grid {
    private Gtk.Label date_label;
    private Gtk.Label time_label;

    public string clock_format { get; set; }
    public string date_format { get; set; }
    public string date_format_custom { get; set; }
    public bool clock_show_seconds { get; set; }
    public bool clock_show_weekday { get; set; }

    construct {
        date_label = new Gtk.Label (null);
        date_label.margin_end = 12;

        var date_revealer = new Gtk.Revealer ();
        date_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        date_revealer.add (date_label);

        time_label = new Gtk.Label (null);

        valign = Gtk.Align.CENTER;
        add (date_revealer);
        add (time_label);

        var clock_settings = new GLib.Settings ("io.elementary.desktop.wingpanel.datetime");
        clock_settings.bind ("clock-format", this, "clock-format", SettingsBindFlags.DEFAULT);
        clock_settings.bind ("clock-show-seconds", this, "clock-show-seconds", SettingsBindFlags.DEFAULT);
        clock_settings.bind ("clock-show-date", date_revealer, "reveal_child", SettingsBindFlags.DEFAULT);
        clock_settings.bind ("clock-show-weekday", this, "clock-show-weekday", SettingsBindFlags.DEFAULT);

        clock_settings.bind ("date-format", this, "date-format", SettingsBindFlags.DEFAULT);
        clock_settings.bind ("date-format-custom", this, "date-format-custom", SettingsBindFlags.DEFAULT);

        notify.connect (() => {
            update_labels ();
        });

        update_labels ();

        Services.TimeManager.get_default ().minute_changed.connect (update_labels);
    }

    private void update_labels () {
        string date_formatString;

        if (date_format == "custom") {
            date_formatString = date_format_custom;
        } else if (date_format == "ISO8601") {
            date_formatString = "%F";
        } else {
            date_formatString = Granite.DateTime.get_default_date_format (clock_show_weekday, true, false);
        }

        string date = Services.TimeManager.get_default ().format (date_formatString);
        if (date == null) { // fallback to default_date_format
            date = Services.TimeManager.get_default ().format (Granite.DateTime.get_default_date_format (clock_show_weekday, true, false));
            warning ("Invalid date format: %s", date_formatString);
        }

        date_label.label = date;

        string time_format = Granite.DateTime.get_default_time_format (clock_format == "12h", clock_show_seconds);
        time_label.label = Services.TimeManager.get_default ().format (time_format);
    }

}
