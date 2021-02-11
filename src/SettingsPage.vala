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

namespace Facade {
    private class Alteration {
        public string window_class;
        public string variant;
        public string comment;

        public Alteration (string window_class, string variant, string comment) {
            this.window_class = window_class;
            this.variant = variant;
            this.comment = comment;
        }

    }

    private class SettingsPage : Granite.SimpleSettingsPage {
        private enum ListViewColumn {
            WINDOW_CLASS,
            VARIANT,
            COMMENT,
            N_COLUMNS
        }

        private Settings settings;
        private Gtk.ListStore settings_store;

        public SettingsPage (Settings settings) {
            Object (
                title: Config.APP_NAME,
                description: "\"Window Class\" contains the `WM_CLASS` property of the desired window. \"Variant\" contains the desired Gtk theme variant to apply to matching windows, e.g. \"dark\"",
                activatable: false);

            this.settings = settings;
            this.settings_store = new Gtk.ListStore (
                ListViewColumn.N_COLUMNS,
                typeof (string), typeof (string), typeof (string));

            settings.changed.connect (on_settings_changed);
            populate_settings_store ();

            settings_store.row_changed.connect (on_settings_store_row_changed);
            settings_store.row_deleted.connect (on_settings_store_row_deleted);
            settings_store.row_inserted.connect (on_settings_store_row_inserted);

            var list_view = new Gtk.TreeView ();

            unowned var selection = list_view.get_selection ();
            selection.set_mode (Gtk.SelectionMode.MULTIPLE);

            list_view.set_model (settings_store);
            list_view.set_activate_on_single_click (true);
            list_view.insert_column_with_attributes (
                -1, "Window Class",
                editable_cell_renderer (ListViewColumn.WINDOW_CLASS), "text", ListViewColumn.WINDOW_CLASS);
            list_view.insert_column_with_attributes (
                -1, "Variant",
                editable_cell_renderer (ListViewColumn.VARIANT), "text", ListViewColumn.VARIANT);
            list_view.insert_column_with_attributes (
                -1, "Comments",
                editable_cell_renderer (ListViewColumn.COMMENT), "text", ListViewColumn.COMMENT);
            list_view.expand = true;

            var actionbar = new Gtk.ActionBar ();
            actionbar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

            var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON);
            add_button.tooltip_text = "Add application style";

            var remove_button = new Gtk.Button.from_icon_name ("list-remove-symbolic", Gtk.IconSize.BUTTON);
            remove_button.tooltip_text = "Remove application style";
            remove_button.sensitive = false;

            actionbar.add (add_button);
            actionbar.add (remove_button);

            var grid = new Gtk.Grid ();
            grid.attach (list_view, 0, 0, 1, 1);
            grid.attach (actionbar, 0, 1, 1, 1);

            var frame = new Gtk.Frame (null);
            frame.add (grid);

            this.content_area.attach (frame, 0, 0, 1, 1);

            add_button.clicked.connect (() => {
                Gtk.TreeIter iter;
                settings_store.append (out iter);
                list_view.set_cursor (settings_store.get_path (iter), null, true);
            });

            list_view.cursor_changed.connect (() => {
                Gtk.TreePath? path;
                unowned Gtk.TreeViewColumn? focus_column;
                list_view.get_cursor (out path, out focus_column);
                remove_button.sensitive = (path != null);
            });

            remove_button.clicked.connect (() => {
                unowned var model = settings_store as Gtk.TreeModel;

                selection.get_selected_rows (out model).@foreach ((path) => {
                    Gtk.TreeIter iter;

                    settings_store.get_iter (out iter, path);
                    settings_store.remove (ref iter);
                });
            });

            this.show_all ();
        }

        private void populate_settings_store () {
            string? window_class;
            string? variant;
            string? comment;
            Gtk.TreeIter settings_store_iterator;
            VariantIter iterator = settings.get_value ("alterations").iterator ();

            while (iterator.next ("(sss)", out window_class, out variant, out comment)) {
                settings_store.append (out settings_store_iterator);
                settings_store.set (
                    settings_store_iterator,
                    ListViewColumn.WINDOW_CLASS, window_class,
                    ListViewColumn.VARIANT, variant, ListViewColumn.COMMENT, comment);
            }
        }

        private Gtk.CellRendererText editable_cell_renderer (ListViewColumn column) {
            var cell_renderer = new Gtk.CellRendererText ();

            cell_renderer.editable = true;
            cell_renderer.edited.connect ((path, data) => {
                Gtk.TreeIter iter;
                Gtk.TreePath tPath = new Gtk.TreePath.from_string (path);

                if (settings_store.get_iter (out iter, tPath) == true)
                    settings_store.@set (iter, column, data);
            });

            return cell_renderer;
        }

        private void on_settings_changed (string key) {
            settings_store.row_changed.disconnect (on_settings_store_row_changed);
            settings_store.row_deleted.disconnect (on_settings_store_row_deleted);
            settings_store.row_inserted.disconnect (on_settings_store_row_inserted);

            settings_store.clear ();
            populate_settings_store ();

            settings_store.row_changed.connect (on_settings_store_row_changed);
            settings_store.row_deleted.connect (on_settings_store_row_deleted);
            settings_store.row_inserted.connect (on_settings_store_row_inserted);
        }

        private void on_settings_store_row_changed (Gtk.TreePath path, Gtk.TreeIter iter) {
            on_settings_store_changed ();
        }

        private void on_settings_store_row_deleted (Gtk.TreePath path) {
            on_settings_store_changed ();
        }

        private void on_settings_store_row_inserted (Gtk.TreePath path, Gtk.TreeIter iter) {
            on_settings_store_changed ();
        }

        private void on_settings_store_changed () {
            settings.changed.disconnect (on_settings_changed);

            var window_class = Value (typeof (string));
            var variant = Value (typeof (string));
            var comment = Value (typeof (string));
            var items = new Array<Variant> ();

            settings_store.@foreach ((model, path, iter) => {
                model.get_value (iter, ListViewColumn.WINDOW_CLASS, out window_class);
                warning (@"window_class: $(window_class.get_string ())");
                model.get_value (iter, ListViewColumn.VARIANT, out variant);
                warning (@"variant: $(variant.get_string ())");
                model.get_value (iter, ListViewColumn.COMMENT, out comment);
                warning (@"comment: $(comment.get_string ())");

                items.append_val (
                    new Variant ("(sss)", window_class.get_string (),
                                 variant.get_string (), comment.get_string ()));

                return false;
            });

            settings.set_value (
                "alterations", new Variant.array (new VariantType ("(sss)"), items.data));
            settings.changed.connect (on_settings_changed);
        }

    }
}
