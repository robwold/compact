class Calculator
  def initialize(adder, subtracter, multiplier, divider)
    @adder = adder
    @subtracter = subtracter
    @multiplier = multiplier
    @divider = divider
  end

  def add(x,y)
    @adder.add(x,y)
  end

  def subtract(x,y)
    @subtracter.subtract(x,y)
  end

  def multiply(x,y)
    @multiplier.multiply(x,y)
  end

  def divide(x,y)
    @divider.divide(x,y)
  end
end