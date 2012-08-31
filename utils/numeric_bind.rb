
# TODO bind to a range
class Numeric
	def bind(a, b)
		if    self < a then a
		elsif self > b then b
		else                self
		end
	end
end

if $0 == __FILE__ || (defined?($TESTING) && $TESTING)
	require 'test/unit'
	class NumericBindTest < Test::Unit::TestCase
		def test_bind
			assert_equal(0.5,  0.5.bind(0.0, 1.0))
			assert_equal(0.0, -0.5.bind(0.0, 1.0))
			assert_equal(1.0, 10.0.bind(0.0, 1.0))
		end
	end # NumericBindTest
end # TESTING

