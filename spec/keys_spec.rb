require File.dirname(__FILE__) + '/spec_helper'

describe Translate::Keys do
  before(:each) do
    @keys = Translate::Keys.new
    @keys.stub!(:files_root_dir).and_return(i18n_files_dir)
  end
  
  describe "to_a" do
    it "extracts keys from I18n lookups in .rb, .html.erb, and .rhtml files" do
      @keys.to_a.map(&:to_s).sort.should == ['article.key1', 'article.key2', 'article.key3', 'article.key4', 'article.key5',
        'category_erb.key1', 'category_html_erb.key1', 'category_rhtml.key1', 'js.alert']
    end
  end
  
  describe "to_hash" do
    it "return a hash with I18n keys and file lists" do
      @keys.to_hash[:'article.key3'].should == ["vendor/plugins/translate/spec/files/translate/app/models/article.rb"]      
    end
  end

  describe "i18n_keys" do
    before(:each) do
      I18n.backend.send(:init_translations) unless I18n.backend.initialized?
    end
    
    it "should return all keys in the I18n backend translations hash" do
      I18n.backend.should_receive(:translations).and_return(translations)
      @keys.i18n_keys(:en).should == ['articles.new.page_title', 'categories.flash.created', 'home.about']
    end
    
    it 'should scope keys by partial' do
      path       = 'app/views/my_controller/my_view.html.erb'
      key        = '.scoped'
      scoped_key = 'my_controller.my_view.scoped'
      
      @keys.send(:scope_key_by_partial, key, path).should == scoped_key
    end
    
  describe "untranslated_keys" do
    before(:each) do
      I18n.stub!(:default_locale).and_return(:en)      
      I18n.backend.stub!(:translations).and_return(translations)
    end
    
    it "should return a hash with keys with missing translations in each locale" do
      Translate::Keys.new.untranslated_keys.should == {
        :sv => ['articles.new.page_title', 'categories.flash.created']
      }
    end
  end
  
  describe "translated_locales" do
    before(:each) do
      I18n.stub!(:default_locale).and_return(:en)
      I18n.stub!(:available_locales).and_return([:sv, :no, :en, :root])
    end
    
    it "returns all avaiable except :root and the default" do
      Translate::Keys.translated_locales.should == [:sv, :no]
    end
  end
  
  describe "to_deep_hash" do
    it "convert shallow hash with dot separated keys to deep hash" do
      Translate::Keys.to_deep_hash(shallow_hash).should == deep_hash
    end
  end
  
  describe "to_shallow_hash" do
    it "converts a deep hash to a shallow one" do
      Translate::Keys.to_shallow_hash(deep_hash).should == shallow_hash
    end
  end

  ##########################################################################
  #
  # Helper Methods
  #
  ##########################################################################

    def translations
      {
        :en => {
          :home => {
            :about => "This site is about making money"
          },
          :articles => {
           :new => {
             :page_title => "New Article"
            }
          },
          :categories => {
            :flash => {
             :created => "Category created"  
            }
          },
          :empty => nil
        },
        :sv => {
          :home => {
            :about => "Denna site handlar om att tjäna pengar"
          }
        }
      }
    end
  end
  
  def shallow_hash
    {
      'pressrelease.label.one' => "Pressmeddelande",
      'pressrelease.label.other' => "Pressmeddelanden",
      'article' => "Artikel",
      'category' => ''
    }    
  end
  
  def deep_hash
    {
      :pressrelease => {
        :label => {
          :one => "Pressmeddelande",
          :other => "Pressmeddelanden"
        }
      },
      :article => "Artikel",
      :category => ''
    }    
  end
  
  def i18n_files_dir
    File.join(ENV['PWD'], "spec", "files", "translate")
  end
end
