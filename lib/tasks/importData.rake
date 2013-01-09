namespace :publisher do 

  task :new_publisher => :environment do
  
    publisher_name = ENV["PUBLISHER"] || "default publisher"
    advertiser_name = ENV["ADVERTISER"] || "default advertiser"
    file_name = ENV["FILENAME"] 
  
  
  
     puts "publisher is #{publisher_name}"
     puts "advertiser is #{advertiser_name}"
     puts "Filename is #{file_name}"
     


     
     @date_regex = /(?:[0-1])?[0-9]\/(?:[0-3])?[0-9]\/[0-9]{2}(?:[0-9]{2})?/ 
     @qty_regex = /(?:[0-9])?[0-9]/
     
     f = File.open("/Users/tprentis/Documents/Deals Test/deal_site/script/data/#{file_name}", "r")
     f.each_line do |line| 

        @adv_name = ""
        @start_at = "0"
        @end_at = "0"
        @proposition = ""
        @price = 0
        @value = 0  
        @ptr1 = 0
        @ptr2 = 0
        @header = true
        
        if @date_regex.match line  #Check for header row
          @header = false
          attr = line.split
          max_attr = attr.size - 1
          attr.each_with_index do |a, i|
            result = @date_regex.match a
            if result 
              @start_at = result.to_s
              @ptr1 = i
              attr[i] = ""
              if i < max_attr 
                result = @date_regex.match attr[i + 1]
                if result 
                   @ptr2 = i + 1
                   @end_at = result.to_s
                   attr[i + 1] = ""                 
                end   
              end      
            end
          end 
          
          # get advertiser name
          @j = 0
          result = ""
          while @j < @ptr1 do 
            result = result + attr[@j] + " "
            @j += 1
          end 
          @adv_name = result.strip
          
          # get price and value
          @price = attr[max_attr - 1] 
          @value = attr[max_attr]
          
          #set up to grab proposition  
          @j = @ptr2
          result = ""
          if @ptr1 > @ptr2
            @j = @ptr1
          end  
          
          #get propostion
          while @j < (max_attr - 1) do
            result = result + attr[@j] + " "
            @j += 1
          end 
          @description = result.strip    
      end     
      if !@header
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
     
        puts "adv name=#{@adv_name}"
        puts "start at=#{@start_at}"
        puts "end_at=#{@end_at}"
        puts "description=#{@description}"
        puts "price=#{@price}"
        puts "value=#{@value}"
        puts "--------------------------"
      end      
    end   
  end
end
