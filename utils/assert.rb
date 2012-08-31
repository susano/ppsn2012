
def assert
	raise RuntimeError.new('Assertion failed') unless yield
	nil
end

if $0 == __FILE__ || (defined?($TESTING) && $TESTING)
	require 'test/unit'
	alias :my_assert :assert 
	class AssertTest < Test::Unit::TestCase

		def test_assert
			assert_raise(RuntimeError) { my_assert{ true == false } }
			assert_equal(nil, my_assert{ true })
		end
	end
end # TESTING

