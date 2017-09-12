module NumbertowordHelper
  # @copyright http://rosettacode.org -- Ruby (Number Names)
  
  SMALL = %w(zero one two three four five six seven eight nine ten
           eleven twelve thirteen fourteen fifteen sixteen seventeen
           eighteen nineteen)
 
  TENS = %w(wrong wrong twenty thirty forty fifty sixty seventy
            eighty ninety)
   
  BIG = [nil, "thousand"] +
        %w( m b tr quadr quint sext sept oct non dec).map{ |p| "#{p}illion" }
   
   
  def wordify number
    if number < 0
      "negative #{wordify -number}"
   
    elsif number < 20
      SMALL[number]
   
    elsif number < 100
      div, mod = number.divmod(10)
      "#{TENS[div]}-#{wordify mod}".chomp("-zero")
   
    elsif number < 1000
      div, mod = number.divmod(100)
      "#{wordify div} hundred and #{wordify mod}".chomp(" and zero")
   
    else
      # separate into 3-digit chunks
      chunks = []
      div = number
      while div != 0
        div, mod = div.divmod(1000)
        chunks << mod # will store smallest to largest
      end
   
      if chunks.length > BIG.length
        raise ArgumentError, "Integer value too large."
      end
   
      chunks.map{ |c| wordify c }.
             zip(BIG). # zip pairs up corresponding elements from the two arrays
             find_all { |c| c[0] != 'zero' }.
             map{ |c| c.join ' '}. # join ["forty", "thousand"]
             reverse.
             join(' and '). # join chunks
             strip
    end
  end
  
end