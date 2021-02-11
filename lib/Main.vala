/*
 * Copyright © 2020 Payson Wallach
 *
 * Released under the terms of the Hippocratic License
 * (https://firstdonoharm.dev/version/1/1/license.html)
 *
 * This file incorporates work covered by the following copyright and
 * permission notice:
 *
 *  The MIT License (MIT)
 *
 *  Copyright (c) 2014 Oktay Acikalin <oktay.acikalin@gmail.com>
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 *  http://opensource.org/licenses/MIT
 */

public class Facade.Plugin : Gala.Plugin {
    private Settings settings;
    private Gee.HashMap<string, string> alterations;
    private Gala.WindowManager wm;

    public override void initialize (Gala.WindowManager wm) {
        this.settings = new Settings (Config.APP_ID);
        this.alterations = get_alterations ();
        this.wm = wm;

#if HAS_MUTTER330
        var display = wm.get_display ();

        update_window_actors (display.get_window_actors ());
        display.window_created.connect (update_window);
#else
        var screen = wm.get_screen ();

        update_window_actors (screen.get_window_actors ());
        screen.get_display ().window_created.connect (update_window);
#endif

        settings.changed.connect (on_settings_changed);
    }

    public override void destroy () {}

    private Gee.HashMap<string, string> get_alterations () {
        string? window_class;
        string? variant;
        VariantIter iterator = settings.get_value ("alterations").iterator ();
        var alterations = new Gee.HashMap<string, string> ();

        while (iterator.next ("(sss)", out window_class, out variant)) {
            alterations[window_class] = variant;
        }

        return alterations;
    }

    private void update_window (Meta.Window window) {
        string instance_name = window.get_wm_class_instance ().down ();
        if (!alterations.has_key (instance_name))
            return;

        ulong window_id = window.get_xwindow ();
        string[] args = {
            "xprop",
            "-id",
            window_id.to_string (),
            "-f",
            "_GTK_THEME_VARIANT",
            "8u",
            "-set",
            "_GTK_THEME_VARIANT",
            alterations[instance_name]
        };

        debug (@"updated window $window_id");

        try {
            new Subprocess.newv (
                args,
                SubprocessFlags.NONE
                );
        } catch (Error err) {
            error (err.message);
        }
    }

    private void update_window_actors (GLib.List<Meta.WindowActor> window_actors) {
        foreach (unowned Meta.WindowActor actor in window_actors) {
            if (actor.is_destroyed ())
                continue;

            update_window (actor.get_meta_window ());
        }
    }

    private void on_settings_changed (string key) {
        var alterations = get_alterations ();
        var changes = new Gee.ArrayList<string> ();

        foreach (var entry in alterations.entries) {
            if (this.alterations.has_key (entry.key)) {
                if (this.alterations[entry.key] != entry.value) {
                    changes.add (entry.key);
                }
            } else {
                changes.add (entry.key);
            }
        }

        this.alterations = alterations;

#if HAS_MUTTER330
        update_window_actors (wm.get_display ().get_window_actors ());
#else
        update_window_actors (wm.get_screen ().get_window_actors ());
#endif
    }

}

public Gala.PluginInfo register_plugin () {
    return Gala.PluginInfo () {
               name = "Facade",
               author = "Payson Wallach <payson@paysonwallach.com>",
               plugin_type = typeof (Facade.Plugin),
               provides = Gala.PluginFunction.ADDITION,
               load_priority = Gala.LoadPriority.IMMEDIATE
    };
}
