# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe 'active_nav_class' do
    it 'returns active when on the current page' do
      allow(helper).to receive(:current_page?).and_return(true)

      result = helper.active_nav_class('/test')
      expect(result).to eq 'active'
    end

    it 'returns active when on a current page' do
      allow(helper).to receive(:current_page?).with('/foo').and_return(false)
      allow(helper).to receive(:current_page?).with('/test').and_return(true)

      result = helper.active_nav_class('/foo', '/test')
      expect(result).to eq 'active'
    end

    it 'returns empty string when not on current page' do
      allow(helper).to receive(:current_page?).and_return(false)

      result = helper.active_nav_class('/test')
      expect(result).to eq ''
    end
  end

  describe 'body_classes' do
    context 'with a body class string from a controller' do
      before do
        without_partial_double_verification do
          allow(helper).to receive(:body_class_string).and_return('modal-layout compose-standalone')
          allow(helper).to receive(:current_flavour).and_return('glitch')
          allow(helper).to receive(:current_skin).and_return('default')
          allow(helper).to receive(:current_account).and_return(Fabricate(:account))
        end
      end

      it 'uses the controller body classes in the result' do
        expect(helper.body_classes).to match(/modal-layout compose-standalone/)
      end
    end
  end

  describe 'locale_direction' do
    around do |example|
      current_locale = I18n.locale
      example.run
      I18n.locale = current_locale
    end

    it 'adds rtl body class if locale is Arabic' do
      I18n.locale = :ar
      expect(helper.locale_direction).to eq 'rtl'
    end

    it 'adds rtl body class if locale is Farsi' do
      I18n.locale = :fa
      expect(helper.locale_direction).to eq 'rtl'
    end

    it 'adds rtl if locale is Hebrew' do
      I18n.locale = :he
      expect(helper.locale_direction).to eq 'rtl'
    end

    it 'does not add rtl if locale is Thai' do
      I18n.locale = :th
      expect(helper.locale_direction).to_not eq 'rtl'
    end
  end

  describe 'fa_icon' do
    it 'returns a tag of fixed-width cog' do
      expect(helper.fa_icon('cog fw')).to eq '<i class="fa fa-cog fa-fw"></i>'
    end
  end

  describe 'open_registrations?' do
    it 'returns true when open for registrations' do
      without_partial_double_verification do
        expect(Setting).to receive(:registrations_mode).and_return('open')
      end

      expect(helper.open_registrations?).to be true
    end

    it 'returns false when closed for registrations' do
      without_partial_double_verification do
        expect(Setting).to receive(:registrations_mode).and_return('none')
      end

      expect(helper.open_registrations?).to be false
    end
  end

  describe 'show_landing_strip?', without_verify_partial_doubles: true do
    describe 'when signed in' do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      it 'does not show landing strip' do
        expect(helper.show_landing_strip?).to be false
      end
    end

    describe 'when signed out' do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(false)
      end

      it 'does not show landing strip on single user instance' do
        allow(helper).to receive(:single_user_mode?).and_return(true)

        expect(helper.show_landing_strip?).to be false
      end

      it 'shows landing strip on multi user instance' do
        allow(helper).to receive(:single_user_mode?).and_return(false)

        expect(helper.show_landing_strip?).to be true
      end
    end
  end

  describe 'title' do
    around do |example|
      site_title = Setting.site_title
      example.run
      Setting.site_title = site_title
    end

    it 'returns site title on production environment' do
      Setting.site_title = 'site title'
      expect(Rails.env).to receive(:production?).and_return(true)
      expect(helper.title).to eq 'site title'
    end
  end
end
