module Edenchain
  module Developer
    module Bounty
      module Data
        
        class Seeder
          class << self
          
            def phone_numbers(size: 1_000_000)
              phone_numbers         =   []
              dir                   =   File.join(File.dirname(__FILE__), "../../../../../files")
              path                  =   File.join(dir, "/phone_numbers.txt")
  
              if ::File.exists?(path)
                phone_numbers       =   File.readlines(path)
              else
                puts "There are no previously generated phone numbers. Generating #{size} phone numbers using Faker (this might take a while depending on how many that needs to be generated)."
              
                size.times do
                  phone_numbers    <<   Faker::PhoneNumber.unique.phone_number
                end
              
                puts "Successfully generated #{size} unique phone numbers!"
            
                FileUtils.mkdir_p dir unless File.exists?(dir)
            
                File.open(path, 'w') do |file|
                  file.write(phone_numbers.join("\n"))
                end
              end
  
              return phone_numbers
            end
          
          end
        end
        
      end      
    end
  end
end
