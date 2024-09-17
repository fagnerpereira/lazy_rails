require "pry"

class FakePrompt
  attr_reader :question, :options, :choices

  def initialize
    @question = nil
    @options = nil
    @choices = []
  end

  def ask(question, **options)
    @question = question
  end

  def select(question, choices = nil, **options)
    @question = question
    @options = options

    if block_given?
      menu = FakeMenu.new
      yield menu
      @choices = menu.choices
    else
      @choices = choices
    end
  end

  alias_method :multi_select, :select

  class FakeMenu
    attr_reader :choices

    def initialize
      @choices = []
    end

    def choice(name, value = name)
      @choices << value
    end
  end
end
