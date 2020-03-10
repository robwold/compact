# COMPACT: COMPrehensive Automated Contract Testing

## Motivation
This library aims to help you combat the problem of drifting test doubles: 
if you change the behaviour of a class upon which other classes depend, and 
you unit test those classes using test doubles in place of the real thing, 
then you run the risk of testing your classes against the old behaviour of 
their dependencies. (Note that this is distinct from the idea of contract tests 
against remote services.)

The traditional approach to guarding against this problem is to complement 
unit tests with integration tests. But Joe Rainsberger would have us believe 
that 
[integration tests are a scam](https://www.infoq.com/presentations/integration-tests-scam/),
and that there are real advantages to verifying the basic correctness of our code with 
[contract tests](https://blog.thecodewhisperer.com/permalink/getting-started-with-contract-tests) instead.

To take a concrete example, let's think about a `Calculator` class that delegates 
responsibility for individual arithmetic operations to classes such as `Adder`. A 
collaboration test looks like
```ruby
class CalculatorTest < MiniTest::Test
  def test_addition_collaboration
    adder = Minitest::Mock.new
    adder.expect(:add,3,[1,2])
    subject = Calculator.new(adder, *other_dependencies)
    assert_equal 3, subject.add(1,2)
  end
  #...
end 
```
To ensure that the expected behaviour of our mock reflects the actual behaviour of our
code, we write a corresponding contract test for the `Adder` class:
```ruby
class AdderTest < MiniTest::Test
  def test_addition_contract
    subject = Adder.new
    assert_equal 3, subject.add(1,2)
  end
end
```
Note the correspondence between the supplied arguments and the return values of the `Adder#add`
method in these tests.

Maintaining this correspondence by hand requires discipline. It becomes significantly harder on 
a team of developers. This gem helps to seek automate maintaining this correspondence.

## Design goals
#### Library agnostic
Whereas some previous steps in this direction have been integrated into specific testing/mocking
libraries such as 
[Bogus](https://relishapp.com/bogus/bogus/v/0-1-6/docs/contract-tests), 
this aims to be something you can drop into an existing test suite and make it immediately more 
robust, whatever test suite or test double library you are using. 
(We're not there yet: see below for the current status.) 

#### Mock roles, not objects
The correspondence between test doubles and objects that fulfill those roles is to be labelled by the
programmer, rather than tied to specific classes.

#### Verify behaviour, not just syntax
It also aims to go one step further than most other such libraries in trying to maintain the 
correspondence between inputs and return values, whereas something like 
[RSpec's verifying doubles](https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles)
just verify that a stubbed method is present on some class.

## Usage
To record the contracts defined by a test double, prepare the double as you normally would but 
inside a block passed to `Compact.prepare_double(role_name)`:
```ruby
class CalculatorTest < MiniTest::Test
  def test_addition_collaboration
    adder = Compact.prepare_double('adder') do
      mock = Minitest::Mock.new
      mock.expect(:add,3,[1,2])
      mock
    end 
    subject = Calculator.new(adder, *other_dependencies)
    assert_equal 3, subject.add(1,2)
  end
  #...
end 
```
This method wraps the return value of the block with a simple decorator that tracks the methods 
dispatched to that double, the arguments with which they are invoked, and the returned values.
It stores these in some state that persists across test runs to produce a summary report at the
end of your test run.

The corresponding enhancement to the contract test is achieved by the method 
`Compact.verify_contract(role_name, object_that_fulfills_role)`. Passing a block to this method in which 
a stubbed method is invoked with the appropriate arguments and returns the correct value verifies 
the contract.
```ruby
class AdderTest < MiniTest::Test
  def test_addition_contract
    adder = Adder.new
    Compact.verify_contract('adder', adder){|adder| assert_equal 3, adder.add(1,2) }
  end
end
```
A contract can fail to be verified in three ways: 
1. A missing contract test
2. A verified method not being asserted by some test_double. 
3. A mismatch in the behaviour of a double and real object intended to fulfill its role.

At the end of your test run Compact will alert you to any instances of all three of these
cases. See the next section for an example.

## A complete example
An executable version of this can be found in `/examples`, and run with `rake examples`. 
Note that the contract tests would normally be written against the classes such as `Adder`
etc. but are interleaved with the collaboration tests in this example to highlight the 
correspondences.

```ruby
require "compact"

# The calculator class delegates its difficult arithmetic
# work to four service classes.
#
# Addition provides a happy example of contract validation.
# Subtraction has a collaboration test without a contract test.
# Multiplication is a collaborator in search of a collaboration.
# Division tells the unhappy story of a soul who's confused about
# whether they want integer or floating point division.
class CalculatorTest < MiniTest::Test

  def test_addition_collaboration
    adder = Compact.prepare_double('adder') do
      adder = Minitest::Mock.new
      adder.expect(:add,3,[1,2])
    end

    subject = Calculator.new(adder, nil, nil, nil)
    subject.add(1,2)
  end

  def test_addition_contract
    adder = Adder.new
    Compact.verify_contract('adder', adder){|adder| assert_equal 3, adder.add(1,2) }
  end

  # NO subtraction contract test!
  def test_subtraction_collaboration
    subtracter = Compact.prepare_double('subtracter') do
      subtracter = Minitest::Mock.new
      subtracter.expect(:subtract,5,[7,2])
    end

    subject = Calculator.new(nil, subtracter, nil, nil)
    subject.subtract(7,2)
  end

  # NO multiplication collaboration test!
  def test_multiplication_contract
    multiplier = Multiplier.new
    Compact.verify_contract('multiplier', multiplier) do |multiplier|
      assert_equal 6, multiplier.multiply(2,3)
    end
  end

  def test_division_collaboration
    divider = Compact.prepare_double('divider') do
      mock = Minitest::Mock.new
      mock.expect(:divide,2.5,[5,2])
    end

    subject = Calculator.new(nil, nil, nil, divider)
    subject.divide(5,2)
  end

  # Mismatched assertion
  def test_division_contract
    divider = Divider.new
    Compact.verify_contract('divider', divider){|divider| assert_equal 2, divider.divide(5,2) }
  end

end

```
Running this produces the following report:
```
The following contracts could not be verified:
Role Name: subtracter
The following methods were invoked on test doubles without corresponding contract tests:
================================================================================
method: subtract
invoke with: [7, 2]
returns: 5
================================================================================
Role Name: multiplier
No test doubles mirror the following verified invocations:
================================================================================
method: multiply
invoke with: [2, 3]
returns: 6
================================================================================
Role Name: divider
Attempts to verify the following method invocations failed:
================================================================================
method: divide
invoke with: [5, 2]
expected: 2.5
Matching invocations returned the following values: [2]
================================================================================
```
## Status
My goals in sharing this publicly at this early stage are:
* To gauge interest in the idea
* To get feedback on the API
* To solicit anyone's input on some areas for further development below.

In version 0.1.0, "Comprehensive" should be understood as an aspiration rather than 
a promise. In particular, I've only written a reporter for Minitest. RSpec is next on the agenda.
Tests have however been written against doubles created using Minitest::Mock, Mocha and `Object.new`. 

And at the risk of stating the obvious, please do not rely on (version 0.1.0 of) this library to prove the basic correctness
of your safety-critical nuclear-powered aerospace software.

Of more pressing concern are some conceptual questions. 

#### Mocks vs stubs
At present the design is clearly skewed towards verifying stubs - i.e. test doubles whose purpose is to 
return a canned value. Matching on return values is a key part of the current verification. We use mocks 
instead if we want to assert that some method is called for its side effects. In Java we would likely be 
able to rely on both mocked and real methods having `void` return signature, but in Ruby we have implicit
returns and all bets are off. This probably motivates the introduction of some less stringent addition to 
the Compact API that fulfills criteria similar to a verifying double.

#### Dependency Injection
This design relies on being able to create an instance of a test double and inject it as a dependency to the subject 
of your collaboration test. Some more sophisticated mocking libraries offer ways in which you can use mocks 
in ways that do not meet this requirement (such as mocking static factory methods). We can't help with that.

#### Class methods
This really generalises the above point. The current API depends crucially on being able to decorate instances
of your test double. I've tried implementations that redefine methods, and they work on a simple `Object.new` stub, 
but instantly explode when you call `test_double.method` on a Minitest mock that isn't expecting to receive `:method`. 
(Minitest::Mock doesn't actually support mocking class methods anyway as far as I am aware.) But it seems like any 
solution to this problem will necessarily require a compromise on the goal of being agnostic about your other tools.

#### Value Objects in method invocations 
The examples above all use integers as the method arguments and return values. When verifying contracts method 
arguments and return values are compared using `==`. It's not clear to me how this approach can be generalised 
to include parameters that are not value objects.

## Installation
I mean ... it's a gem. 

Add this line to your application's Gemfile:

```ruby
gem 'compact'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install compact


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/robwold/compact. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Compact project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/compact/blob/master/CODE_OF_CONDUCT.md).
