require 'spec_helper'

# User Story #1 - Parse account numbers
describe 'BankOCR', fakefs: true do
	let(:fileName) { '/tmp/accounts.txt' }
	let(:expectedNumbersCount) { 5 }
	def create_test_account_file(file)
		zeros =				[	" _  _  _  _  _  _  _  _  _ ",
               					"| || || || || || || || || |",
               					"|_||_||_||_||_||_||_||_||_|"].join("\n")

    	ones =				[	"                           ",
           						"  |  |  |  |  |  |  |  |  |",
           						"  |  |  |  |  |  |  |  |  |"].join("\n")

        twos = 				[	" _  _  _  _  _  _  _  _  _ ",
 								" _| _| _| _| _| _| _| _| _|",
								"|_ |_ |_ |_ |_ |_ |_ |_ |_ "].join("\n")

		zero_to_eight = 	[	" _     _  _     _  _  _  _ ",
 								"| |  | _| _||_||_ |_   ||_|",
								"|_|  ||_  _|  | _||_|  ||_|"].join("\n")

		nine_to_one = 		[	" _  _  _  _  _     _  _    ",
 								"|_||_|  ||_ |_ |_| _| _|  |",
								" _||_|  ||_| _|  | _||_   |"].join("\n")

		File.open(file, 'w') do |f|
			f.puts(zeros + "\n\n")
			f.puts(ones + "\n\n")
			f.puts(twos + "\n\n")
			f.puts(zero_to_eight + "\n\n")
			f.puts(nine_to_one + "\n\n")

		end
	end

	before(:all) { create_test_account_file('/tmp/accounts.txt') }

	context 'when input file does not exist' do
		it 'raises Errno::ENOENT' do
			expect { BankOCR.new('/etc/accounts-non-existent.txt') }.to raise_error(Errno::ENOENT)
		end
	end

	context 'when account number is valid' do
		it 'the calculated checksum is valid' do
			ocr = BankOCR.new(fileName)
			correctNumbers = "345882865"

			expect(ocr.validate_checksum(correctNumbers)).to eq("")
		end
	end

	context 'when account number is invalid' do
		it 'the calculated checksum is invalid' do
			ocr = BankOCR.new(fileName)
			correctNumbers = "345882845"

			expect(ocr.validate_checksum(correctNumbers)).to eq("ERR")
		end
	end

	context 'when account number has unrecognized digits' do
		it 'the calculated checksum is invalid' do
			ocr = BankOCR.new(fileName)
			correctNumbers = "3458828?5"

			expect(ocr.validate_checksum(correctNumbers)).to eq("ILL")
		end
	end

	context 'when input file exists' do
		
		describe "reading properly OCR'd account numbers", fakefs: true do
			
			it 'has content' do
				ocr = BankOCR.new(fileName)
				expect(ocr.fileContents).not_to be_empty
			end

			it 'creates numbers map' do
				ocr = BankOCR.new(fileName)
				numbers_map = ocr.create_numbers_map(ocr.fileContents)
				expect(numbers_map.length).to eql(expectedNumbersCount)
			end

			it 'correctly creates numbers map' do
				ocr = BankOCR.new(fileName)

				numbers_map = ocr.create_numbers_map(ocr.fileContents)
				expected_map = 
				[
					[
						" _  _  _  _  _  _  _  _  _ ".split(""),
						"| || || || || || || || || |".split(""),
						"|_||_||_||_||_||_||_||_||_|".split("")
					],
					[
						"                           ".split(""),
						"  |  |  |  |  |  |  |  |  |".split(""),
						"  |  |  |  |  |  |  |  |  |".split("")
					],
					[
						" _  _  _  _  _  _  _  _  _ ".split(""),
						" _| _| _| _| _| _| _| _| _|".split(""),
						"|_ |_ |_ |_ |_ |_ |_ |_ |_ ".split("")
					],
					[
						" _     _  _     _  _  _  _ ".split(""),
						"| |  | _| _||_||_ |_   ||_|".split(""),
						"|_|  ||_  _|  | _||_|  ||_|".split("")
					],
					[
						" _  _  _  _  _     _  _    ".split(""),
						"|_||_|  ||_ |_ |_| _| _|  |".split(""),
						" _||_|  ||_| _|  | _||_   |".split("")
					]
				]
				expect(numbers_map).to eql(expected_map)
			end

			it 'correctly detects zero' do
				ocr = BankOCR.new(fileName)
				zero = [[" ", "_", " "],
             			["|", " ", "|"],
             			["|", "_", "|"]]
				detectedDigit = ocr.detect_digit(zero)
				expect(detectedDigit).to eq("0")
			end

			it 'correctly detects three' do
				ocr = BankOCR.new(fileName)
				three = [[" ", "_", " "],
             			 [" ", "_", "|"],
             			 [" ", "_", "|"]]
				detectedDigit = ocr.detect_digit(three)
				expect(detectedDigit).to eq("3")
			end

			it 'correctly detects four' do
				ocr = BankOCR.new(fileName)
				four = [[" ", " ", " "],
	 		 			["|", "_", "|"],
	 		 			[" ", " ", "|"]]
				detectedDigit = ocr.detect_digit(four)
				expect(detectedDigit).to eq("4")
			end

			it 'correctly detects five' do
				ocr = BankOCR.new(fileName)
				five = [[" ", "_", " "],
	 		 			["|", "_", " "],
	 		 			[" ", "_", "|"]]
				detectedDigit = ocr.detect_digit(five)
				expect(detectedDigit).to eq("5")
			end

			it 'correctly detects six' do
				ocr = BankOCR.new(fileName)
				six =  [[" ", "_", " "],
	 		 			["|", "_", " "],
	 		 			["|", "_", "|"]]
				detectedDigit = ocr.detect_digit(six)
				expect(detectedDigit).to eq("6")
			end

			it 'correctly detects seven' do
				ocr = BankOCR.new(fileName)
				seven =  [[" ", "_", " "],
	 		 			  [" ", " ", "|"],
	 		 			  [" ", " ", "|"]]
				detectedDigit = ocr.detect_digit(seven)
				expect(detectedDigit).to eq("7")
			end

			it 'correctly detects one digit' do
				ocr = BankOCR.new(fileName)
				one = [	[" ", " ", " "],
             			[" ", " ", "|"],
             			[" ", " ", "|"]]
				detectedDigit = ocr.detect_digit(one)
				expect(detectedDigit).to eq("1")
			end

			it 'correctly detects two digit number' do
				ocr = BankOCR.new(fileName)
				ten = [
							[" ", " ", " ", " ", "_", " "],
             				[" ", " ", "|", "|", " ", "|"],
             				[" ", " ", "|", "|", "_", "|"]
             			]
				detectedNumber = ocr.detect_number(ten)
				expect(detectedNumber).to eq("10")
			end

			it 'correctly detects five digit number' do
				ocr = BankOCR.new(fileName)
				ten_thousand = [
							[" ", " ", " ", " ", "_", " ", " ", "_", " ", " ", "_", " ", " ", "_", " "],
             				[" ", " ", "|", "|", " ", "|", "|", " ", "|", "|", " ", "|", "|", " ", "|"],
             				[" ", " ", "|", "|", "_", "|", "|", "_", "|", "|", "_", "|", "|", "_", "|"]
             			]
				detectedNumber = ocr.detect_number(ten_thousand)
				expect(detectedNumber).to eq("10000")
			end

			it 'parses all account numbers' do
				ocr = BankOCR.new(fileName)
				account_numbers = ocr.parse_account_numbers
				expect(account_numbers.length).to eql(expectedNumbersCount)
			end

			it 'correctly generates all digits map for ten' do
				ocr = BankOCR.new(fileName)
				ten = [
						[" ", " ", " ", " ", "_", " "],
         				[" ", " ", "|", "|", " ", "|"],
         				[" ", " ", "|", "|", "_", "|"]
         			]
				allDigitMaps = ocr.generate_all_digits_map(ten)
				expect(allDigitMaps).to eql(
					[
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						],
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						]
					])

			end

			it 'correctly generates all digits map for zeros' do
				ocr = BankOCR.new(fileName)
				
         		zeros =	[
							" _  _  _  _  _  _  _  _  _ ".split(""),
							"| || || || || || || || || |".split(""),
							"|_||_||_||_||_||_||_||_||_|".split("")
						]
				allDigitMaps = ocr.generate_all_digits_map(zeros)
				expect(allDigitMaps).to eql(
					[
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						],
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						],
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						],
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						],
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						],
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						],
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						],
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						],
						[
							[" ", "_", " "],
							["|", " ", "|"],
							["|", "_", "|"]
						]
					])

			end

			it 'correctly generates all digits map for ones' do
				ocr = BankOCR.new(fileName)
				
         		ones =	[
						"                           ".split(""),
						"  |  |  |  |  |  |  |  |  |".split(""),
						"  |  |  |  |  |  |  |  |  |".split("")
					]
				allDigitMaps = ocr.generate_all_digits_map(ones)
				expect(allDigitMaps).to eql(
					[
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						],
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						],
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						],
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						],
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						],
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						],
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						],
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						],
						[
							[" ", " ", " "],
							[" ", " ", "|"],
							[" ", " ", "|"]
						]
					])

			end

			it 'correctly generates all digits map for twos' do
				ocr = BankOCR.new(fileName)
				
         		twos =	[
						" _  _  _  _  _  _  _  _  _ ".split(""),
						" _| _| _| _| _| _| _| _| _|".split(""),
						"|_ |_ |_ |_ |_ |_ |_ |_ |_ ".split("")
					]
				allDigitMaps = ocr.generate_all_digits_map(twos)
				expect(allDigitMaps).to eql(
					[
						[
							[" ", "_", " "],
							[" ", "_", "|"],
							["|", "_", " "]
						],
						[
							[" ", "_", " "],
							[" ", "_", "|"],
							["|", "_", " "]
						],
						[
							[" ", "_", " "],
							[" ", "_", "|"],
							["|", "_", " "]
						],
						[
							[" ", "_", " "],
							[" ", "_", "|"],
							["|", "_", " "]
						],
						[
							[" ", "_", " "],
							[" ", "_", "|"],
							["|", "_", " "]
						],
						[
							[" ", "_", " "],
							[" ", "_", "|"],
							["|", "_", " "]
						],
						[
							[" ", "_", " "],
							[" ", "_", "|"],
							["|", "_", " "]
						],
						[
							[" ", "_", " "],
							[" ", "_", "|"],
							["|", "_", " "]
						],
						[
							[" ", "_", " "],
							[" ", "_", "|"],
							["|", "_", " "]
						]
					])

			end

			it 'correctly determines all account numbers' do
				ocr = BankOCR.new(fileName)
				account_numbers = ocr.parse_account_numbers
				expect(account_numbers).to eql(["000000000", "111111111", "222222222", "012345678", "987654321"])
			end
		end
	end
end