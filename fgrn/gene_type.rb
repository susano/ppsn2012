require 'fgrn/fgrn'

class Fgrn::GeneType

	TYPE = {
		:behavioural   => 1,
		:regulatory    => 2,
		:receptor      => 4,
		:environmental => 8
	}

	BEHAVIOURAL   = TYPE[:behavioural  ]
	REGULATORY    = TYPE[:regulatory   ]
	RECEPTOR      = TYPE[:receptor     ]
	ENVIRONMENTAL = TYPE[:environmental]

	# from hash
	def self.from_hash(hash)
		self.new(hash[:type])
	end

	# ctor
	def initialize(type)
		@type = type
	end

	# clone
	def clone
		Fgrn::GeneType.new(@type)
	end

	# mutate this
	def mutate!(mutation_rate)
		@type ^= (1 << rand(4)) if rand < mutation_rate
	end

	def behavioural?  ; (@type & BEHAVIOURAL  ) != 0 end
	def regulatory?   ; (@type & REGULATORY   ) != 0 end
	def receptor?     ; (@type & RECEPTOR     ) != 0 end
	def environmental?; (@type & ENVIRONMENTAL) != 0 end

	# to string
	def to_s
		[[:behavioural  , 'B'],
		 [:regulatory   , 'R'],
		 [:receptor     , 'C'],
		 [:environmental, 'E']].collect{ |key, letter| (@type & TYPE[key]) != 0 ? letter : '-' }.join('')
	end # to_s

	# to hash
	def to_hash
		{
			:type => @type
		}
	end
end # Fgrn::GeneType

