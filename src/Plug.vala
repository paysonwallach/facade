/*
 * Copyright (c) 2021 Payson Wallach
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 */

public class Facade.Plug : Switchboard.Plug {
    private Settings settings = new Settings (Config.APP_ID);
    private SettingsPage widget;

    public Plug () {
        Object (
            category: Category.PERSONAL,
            code_name: Config.APP_ID,
            display_name: Config.APP_NAME,
            description: "Customise the appearance of Gtk applications",
            icon: "facade");
    }

    construct {
        Gtk.IconTheme.get_default ()
            .add_resource_path ("/com/paysonwallach/facade/icons");
    }

    public override Gtk.Widget get_widget () {
        if (widget == null)
            widget = new SettingsPage (settings);

        return widget;
    }

    public override void shown () {}

    public override void hidden () {}

    public override void search_callback (string location) {}

    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> ();

        search_results.set (@"$(display_name) → Appearance", "appearance");

        return search_results;
    }

}

public Switchboard.Plug get_plug (Module module) {
    debug ("activating Facade plug");
    var plug = new Facade.Plug ();
    return plug;
}
