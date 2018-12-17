#-- copyright
# ReportingEngine
#
# Copyright (C) 2010 - 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#++

class Widget::Settings < Widget::Base
  dont_cache! # Settings may change due to permissions

  @@settings_to_render = [:filter, :group_by, :controls]

  def render_filter_settings
    render_widget Widget::Settings::Fieldset, @subject,
                  type: 'filters'  do
      render_widget Widget::Filters, @subject
    end
  end

  def render_group_by_settings
    render_widget Widget::Settings::Fieldset, @subject,
                  type: 'group_by'  do
      render_widget Widget::GroupBys, @subject
    end
  end

  def render_controls_settings
    content_tag :div, class: 'form--buttons -with-button-form' do
      widgets = ''.html_safe
      render_widget(Widget::Controls::Apply, @subject, to: widgets)
      render_widget(Widget::Controls::Save, @subject, to: widgets,
                                                      can_save: allowed_to?(:save, @subject, current_user))
      if allowed_to?(:create, @subject, current_user)
        render_widget(Widget::Controls::SaveAs, @subject, to: widgets,
                                                          can_save_as_public: allowed_to?(:save_as_public, @subject, current_user))
      end
      render_widget(Widget::Controls::Clear, @subject, to: widgets)
      render_widget(Widget::Controls::Delete, @subject, to: widgets,
                                                        can_delete: allowed_to?(:destroy, @subject, current_user))
    end
  end

  def render
    write(form_tag('#', id: 'query_form', method: :post) do
      content_tag :div, id: 'query_form_content' do
        # will render a setting menu for every setting.
        # To add new settings, write a new instance method render_<a name>_setting
        # and add <a name> to the @@settings_to_render list.
        content = ''.html_safe
        @@settings_to_render.each do |setting_name|
          render_method_name = "render_#{setting_name}_settings"
          content << send(render_method_name) if respond_to? render_method_name
        end
        content
      end
    end)
  end
end
