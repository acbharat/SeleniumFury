module PageObjectComponents
  # when this module is loaded, add on the ClassMethods module
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
# this is a method on the class now
#@method element(element_sym, element_hash, opts={})
# @param element_sym [:Symbol]
# @param element_hash [Hash]
# @param opts [Hash]
# @return [Selenium::WebDriver::Element]
    def element(element_sym, element_hash, opts={})

      @transient_elements ||= []
      @elements ||= []

      # define a new method with the name of the symbol after locator that returns the value
      send :define_method, element_sym do
        wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
        begin
          wait.until { driver.find_element element_hash }
        rescue Selenium::WebDriver::Error::TimeOutError
          raise "Could not find element #{element_sym}"
        end
      end

      # keep a running track of all elements and transient elements
      @elements << element_sym
      @transient_elements << element_hash if opts[:transient]

    end

# @method page(page_sym, page_class)
# @param page_sym [:Symbol]
# @param page_class [Class]
# @return [PageObject]
    def page(page_sym, page_class)
      send :define_method, page_sym do
        raise "#{page_class} does not inherit from PageObject" unless page_class.superclass == PageObject
        page_class.new(driver)
      end
    end
  end
end