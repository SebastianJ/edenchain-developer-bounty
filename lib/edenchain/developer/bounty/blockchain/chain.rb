module Edenchain
  module Developer
    module Bounty
      module Blockchain
        
        class Chain
          # Initial starting parameters for the Proof of Work (PoW) implementation
          PROOF_OF_WORK               =   {
            # Naive difficulty, just look for hashes starting with leading zeroes
            difficulty: "0",
            
            # Increase the difficulty, i.e. adding another leading zero, every 250 blocks
            increase_every: 250
          }
          
          # Naive lookup - uses a format of BLOCKHEIGHTxDataItemHash to check if a specific date item (e.g. a phone number exists in any blocks)
          # E.g. 12345xa8f380f815b9459c63d6ba347d8f9134fc71d4ff5f2cb9932f5dcdadc31de51a
          # Block height -> 12345
          # Item hash -> a8f380f815b9459c63d6ba347d8f9134fc71d4ff5f2cb9932f5dcdadc31de51a
          ADDRESS_PATTERN     =   /^(?<block_height>\d*)x{1}(?<hash>[a-z0-9]*)$/i
          
          attr_reader :blocks, :block_height, :block_size
          attr_reader :proof_of_work
          attr_reader :address_pattern
          
          # Super naive block size limitation - just limits the number of data items a certain block can have when iterating over the data items
          # It's not enforced in the actual blocks for now because, muh, lazy.
          
          def initialize(enable_pow: false, block_size: 1_000, data: [], verbose: false)
            @blocks           =   {}
            @block_height     =   0
            @block_size       =   block_size
            
            @proof_of_work    =   {
              enabled:    enable_pow,
              difficulty: enable_pow ? PROOF_OF_WORK[:difficulty] : nil
            }
            
            @verbose          =   verbose
            
            set_blocks(data)
          end
          
          def set_blocks(data)
            data.each_slice(@block_size) do |segment|
              if @blocks.empty?
                @blocks[@block_height]   =  Block.first(segment, proof_of_work_difficulty)
                @block_height           +=  1
              elsif !@blocks.empty? && current_block
                @blocks[@block_height]   =  Block.next(current_block, segment, proof_of_work_difficulty)
                @block_height           +=  1
              end
            end if data&.any?
          end
          
          def proof_of_work_difficulty
            if @proof_of_work[:enabled]
              log("Proof of Work is enabled. Current Proof of Work difficulty: #{@proof_of_work[:difficulty].length}. Current block height: #{@block_height}")
              
              if @block_height % PROOF_OF_WORK[:increase_every] == 0
                count                          =   (@block_height / PROOF_OF_WORK[:increase_every])
                
                unless count.zero?
                  @proof_of_work[:difficulty] +=   "0"
                  log("Proof of Work difficulty has now been increased since we've reached a new block height that should trigger a new difficulty level. Current Proof of Work difficulty: #{@proof_of_work[:difficulty].length}. Current block height: #{@block_height}")
                end
              end
            end

            return @proof_of_work[:difficulty]
          end
          
          def log(message)
            puts message if @verbose
          end
          
          def current_block
            @blocks.fetch(@block_height - 1, nil)
          end
          
          def lookup(hash)
            matches     =   hash.match(ADDRESS_PATTERN)
            height      =   matches&.[](:block_height)&.to_i
            item_hash   =   matches&.[](:hash)
            included    =   false
            
            #puts "Trying to resolve an item using address #{hash}. Block height: #{height}. Item hash: #{item_hash}"
            
            if height && item_hash
              included  =   @blocks[height].data.include?(item_hash)
            else
              puts "Couldn't locate any data items for hash #{hash}"
            end
            
            return {block_height: height, included: included}
          end

          def include?(hash)
            return lookup(hash)[:included]
          end
          
        end
        
      end
    end
  end
end
