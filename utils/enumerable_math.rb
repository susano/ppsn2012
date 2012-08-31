
module Enumerable
	# Get the mean of an enumeration of numerical elements; defaults to 0.0.
	def mean
		(self.size == 0) ? 0.0 : self.inject(&:+).to_f / self.size
	end

	# Get the median of the elements; if there is an even number of elements
	# return the mean of the two median elements.
	def median
		if self.size == 0
 		 	nil
 		else
			sorted = self.sort
			if sorted.size % 2 == 0
				(sorted[sorted.size / 2] + sorted[(sorted.size / 2) - 1]) / 2.0
			else
				sorted[sorted.size / 2]
			end
		end
	end

	# Get the median of the elements; if there is an even number of elements
	# return the highest of the two median elements.
	def median_ceil
		if self.size == 0
 		 	nil
 		else
			sorted = self.sort
			if sorted.size % 2 == 0
				sorted[sorted.size / 2]
			else
				sorted[sorted.size / 2]
			end
		end
	end

	# Get the median of the elements; if there is an even number of elements
	# return the lowest of the two median elements.
	def median_floor
		if self.size == 0
 		 	nil
 		else
			sorted = self.sort
			if sorted.size % 2 == 0
				sorted[(sorted.size / 2) - 1]
			else
				sorted[sorted.size / 2]
			end
		end
	end

	# get the percentile +p+ of the enumberable, by rank.
	def percentile_rank(p)
			if p < 0.0 || p > 100.0
				nil
			else
				size = self.size 
				if size == 0
					nil
				elsif size == 1
					self[0]
				else
					sorted = self.sort
					i = (p * size / 100.0).floor
					i = size - 1 if i == size
					sorted[i]
			end # size ==
		end # p < 0.0 || p > 100.0
	end

	alias :percentile :percentile_rank

	# Get the standard deviation across an enumeration of numerical elements;
	# defaults to 0.0.
	def standard_deviation
		if (self.size == 0)
			0.0
		else
			mean = self.mean
			Math.sqrt(self.collect{ |e| (mean - e) ** 2.0 }.inject(&:+) / self.size)
		end
	end

	alias :stddev :standard_deviation
end # Enumerable

if $0 == __FILE__ || (defined?($TESTING) && $TESTING)
	require 'test/unit'
	class EnumerableMathTest < Test::Unit::TestCase

		def test_mean
			assert_equal(1.0,  [1, 1, 1, 1.0, 1.0].mean)
			assert_equal(4.0,  (1..7).to_a.mean)
			assert_equal(0.0,  [].mean)
			assert_equal(5.2,  [5.2].mean)
		end

		def test_median
			assert_equal(3,   [1, 2, 3, 4, 5].median)
			assert_equal(3,   [5, 1, 5, 2, 3].median)
			assert_equal(2.5, [1, 2, 3, 4].median)
			assert_equal(1.0, [0.0, 2.0, 2.0, 0.0].median)
			assert_equal(1.0, [0.0, 2.0, 2.0, 0.0, 1.0].median)
		end

		def test_median_floor
			assert_equal(3,   [1, 2, 3, 4, 5].median_floor)
			assert_equal(3,   [5, 1, 5, 2, 3].median_floor)
			assert_equal(2,   [1, 2, 3, 4].median_floor)
			assert_equal(0.0, [0.0, 2.0, 2.0, 0.0].median_floor)
			assert_equal(1.0, [0.0, 2.0, 2.0, 0.0, 1.0].median_floor)
		end

		def test_median_ceil
			assert_equal(3,   [1, 2, 3, 4, 5].median_ceil)
			assert_equal(3,   [5, 1, 5, 2, 3].median_ceil)
			assert_equal(3,   [1, 2, 3, 4].median_ceil)
			assert_equal(2.0, [0.0, 2.0, 2.0, 0.0].median_ceil)
			assert_equal(1.0, [0.0, 2.0, 2.0, 0.0, 1.0].median_ceil)
		end

		def test_percentile_rank
			a = [30, 20, 60, 10, 50, 40]
			assert_equal(10, a.percentile_rank(0.0))
			assert_equal(10, a.percentile_rank(12.0))
			assert_equal(20, a.percentile_rank(18.0))
			assert_equal(20, a.percentile_rank(25.0))
			assert_equal(20, a.percentile_rank(30.0))
			assert_equal(30, a.percentile_rank(34.0))
			assert_equal(30, a.percentile_rank(49.5))
			assert_equal(40, a.percentile_rank(50.5))
			assert_equal(50, a.percentile_rank(67.0))
			assert_equal(60, a.percentile_rank(95.0))
			assert_equal(60, a.percentile_rank(100.0))
		end

		def test_standard_deviation
			assert_equal(0.0,  [].standard_deviation)
			assert_equal(2.0,  [2, 4, 4, 4, 5, 5, 7, 9].standard_deviation) # wikipedia example
		end
	end # EnumerableMathTest
end # TESTING

