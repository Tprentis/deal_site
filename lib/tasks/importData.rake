namespace :publisher do 

  task :new_publisher => :environment do
    
    if !ENV["PUBLISHER"]
      puts "Plase supply  -> PUBLISHER="
      exit_flag = true
    end
    
    if !ENV["FILENAME"]
      puts "Plase supply  -> FILENAME="
      exit_flag = true
    end

    if exit_flag
      puts "Import Operation Aborted"
      exit
    end
  
    publisher_name = ENV["PUBLISHER"] 
    file_name = ENV["FILENAME"] 
  
    puts "publisher is #{publisher_name}"
    puts "Filename is #{file_name}"
     
    DATE_REGEX = /(?:[0-1])?[0-9]\/(?:[0-3])?[0-9]\/[0-9]{2}(?:[0-9]{2})?/ 
    NUM_REGEX = /(?:[0-9])?[0-9]/
    LOGFILE = "#{Rails.root}/script/data/importData.log"

    logger = Logger.new(LOGFILE)

     
     # TPP Open input file
     f = File.open("#{Rails.root}/script/data/#{file_name}", "r")
     
     f.each_line do |line| 
       
        # TPP init work variables
        @adv_name = ""
        @start_at = ""
        @end_at = ""
        @proposition = ""
        @price = 0
        @value = 0  
        @ptr1 = 0
        @ptr2 = 0
        @header = true
        
        if DATE_REGEX.match line  #TPP - Check for header row (i.e. if there is no date present)
          @header = false  # TPP - turn off header test
          attr = line.split
          max_attr = (attr.size - 1)
          
          # TPP - find start_at and end_at if exists
          attr.each_with_index do |a, i|
            result = DATE_REGEX.match a
            if result 
              @start_at = result.to_s
              @start_at = @start_at.strip
              @ptr1 = i
              attr[i] = ""
              if i < max_attr 
                result = DATE_REGEX.match attr[i + 1]
                if result 
                  @ptr2 = i + 1
                  @end_at = result.to_s 
                  @end_at = @end_at.strip 
                  attr[i + 1] = ""
                else
                  @end_at = Time.zone.now + 24.hours  # TPP no end date provided so substitute                  
                end   
              end
            end
          end 

        
          # get advertiser name
          j = 0
          result = ""
          while j < @ptr1 do 
            result = result + attr[j] + " "
            j += 1
          end 
          @adv_name = result.strip
          
          # get price and value
          @price = attr[max_attr - 1].strip 
          if !NUM_REGEX.match @price  # TPP - make sure @price is a number
            @price = 0
          end
          @value = attr[max_attr].strip
          if !NUM_REGEX.match @value  # TPP - make sure @value is a number
            @value = 0
          end
          
          #set up to grab proposition  
          j = @ptr2 + 1
          result = ""
          if @ptr1 > @ptr2
            j = @ptr1 + 1 # TPP - end_at must be absent
          end  
          
          #get propostion
          while j < (max_attr - 1) do
            result = result + attr[j] + " "
            j += 1
          end 
          @description = result.strip         
               
          puts "adv name=#{@adv_name}"
          puts "start at=#{@start_at}"
          puts "end_at=#{@end_at}"
          puts "description=#{@description}"
          puts "price=#{@price}"
          puts "value=#{@value}"
          puts "--------------------------"
          
          logger.info "adv name=#{@adv_name}"
          logger.info "start at=#{@start_at}"
          logger.info "end_at=#{@end_at}"
          logger.info "description=#{@description}"
          logger.info "price=#{@price}"
          logger.info "value=#{@value}"
          logger.info "--------------------------"


          adv = Advertiser.find_or_initialize_by_name("#{@adv_name}")
          pub = Publisher.find_or_initialize_by_name("#{publisher_name}")
          deal = Deal.new
     
          pub.parent_id = adv.id
          pub.name = publisher_name
          pub.theme = "entertainment-generic"
     
          pub.save
     
          adv.publisher_id = pub.id
          adv.name = @adv_name

          adv.save
 
          deal.proposition = "Big Deal!"
          deal.value = @value
          deal.price = @price
          deal.advertiser_id = adv.id
          deal.description = @description
          deal.start_at = @start_at
          deal.end_at = @end_at
     
          deal.save
        else
          
            puts "Questionable Record: " + line  
            logger.info "Questionable Record: " + line      
            
        end  # TPP - if !@header    
      end  # TPP - end file read each_line loop   
  end # TPP - task do 
end # TPP - namespace do
