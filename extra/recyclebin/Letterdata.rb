
    #
    # nested_array.each do |word|
    #   word.each do |ldata|
    #     unless @array.list_attribute(:name).include?(ldata.name)
    #       @array << ldata
    #     else
    #       ldata.instance_variables.each do |var|
    #         twin = @array.return_object_with(:name, ldata.name)
    #
    #         var_name = var.to_s.delete("@")
    #         current_value = twin.instance_variable_get(var)
    #         var_value = ldata.instance_variable_get(var)
    #         puts "#{var_name} #{var_value}"
    #         if current_value
    #           new_value = current_value + var_value
    #         else
    #           new_value = var_value
    #         end
    #         p var.to_sym
    #         twin.instance_variable_set(var.to_sym, new_value)
    #       end
    #     end
    #   end
    # end
