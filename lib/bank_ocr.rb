require 'digit_constants'

class BankOCR
	attr_accessor :fileContents
	attr_accessor :account_numbers_map
	attr_accessor :account_numbers
	attr_accessor :all_digits_map

	def initialize(fileName)
		@fileContents = IO.readlines(fileName)
		@account_numbers = []
		@account_numbers_map = []
		@all_digits_map = []
	end

	def parse_account_numbers
		numbers_map = create_numbers_map(@fileContents)
		numbers_map.each do |single_number_map|
			detected_number = detect_number(single_number_map)
			@account_numbers.push(detected_number)
		end
		@account_numbers
	end

	def create_numbers_map(lines)
		if !lines.last.strip.empty?
			lines.push("\n") #Ensure that there is a blank line in the end to ease number detection
		end
		numbers_map = []
		single_line_map = []
		line_number = 1

		lines.each do |line|
			if line_number % 4 != 0
				single_line_map.push(line.tr("\n", "").split(""))
			else
				numbers_map.push(single_line_map)
				single_line_map = []
			end
			line_number = line_number + 1
		end
		numbers_map
	end

	def detect_number(singleNumberMap)
		

		return nil if singleNumberMap.empty?
		cumulative = ""
		@all_digits_map = generate_all_digits_map(singleNumberMap)

		@all_digits_map.each do |digit_map|
			digit = detect_digit(digit_map)
			if !digit.nil?
				cumulative << digit
			else
				cumulative << "?"
			end
		end
		
		cumulative
	end

	def detect_digit(digitMap)
		case digitMap
			when DigitConstants::ZERO
				return "0"
			when DigitConstants::ONE
				return "1"
			when DigitConstants::TWO
				return "2"
			when DigitConstants::THREE
				return "3"
			when DigitConstants::FOUR
				return "4"
			when DigitConstants::FIVE
				return "5"
			when DigitConstants::SIX
				return "6"
			when DigitConstants::SEVEN
				return "7"
			when DigitConstants::EIGHT
				return "8"
			when DigitConstants::NINE
				return "9"
			else
				return nil
			end
	end

	def generate_all_digits_map(singleNumberMap)
		all_digits_map = []
		start = 0
		edge = 2
		while edge <= singleNumberMap[0].length do
			digitMap = []
			(0..singleNumberMap.length - 1).each do |i|
				digitMap.push(singleNumberMap[i][start..edge])
			end	
			all_digits_map.push(digitMap)
			start = start + 3
			edge = edge + 3
		end
		all_digits_map
	end
end