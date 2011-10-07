module SwfFu
  class Generator
    VALID_MODES = [:static, :dynamic]

    def initialize(source, options, view)
      @view   = view
      @source = view.swf_path(source)
      options = ActionView::Base.swf_default_options.merge(options)

      [:html_options, :parameters, :flashvars].each do |k|
        options[k] = convert_to_hash(options[k]).reverse_merge convert_to_hash(ActionView::Base.swf_default_options[k])
      end

      options.reverse_merge!(SwfFu::DEFAULTS)
      options[:id] ||= source.gsub(/^.*\//, '').gsub(/\.swf$/,'')
      options[:div_id] ||= options[:id]+"_div"
      options[:width], options[:height] = options[:size].scan(/^(\d*%?)x(\d*%?)$/).first if options[:size]
      options[:auto_install] &&= @view.swf_path(options[:auto_install])
      options[:flashvars][:id] ||= options[:id]
      @mode = options.delete(:mode)
      @options = options

      unless VALID_MODES.include? @mode
        raise ArgumentError, "options[:mode] should be either #{VALID_MODES.join(' or ')}"
      end
    end

    def generate(&block)
      if block_given?
        @options[:alt] = @view.capture(&block)
        @view.concat(send(@mode))
      else
        send(@mode)
      end
    end

    def convert_to_hash(s)
      case s
      when Hash
        s
      when nil
        {}
      when String
        s.split("&").inject({}) do |h, kvp|
          key, value    = kvp.split("=")
          h[key.to_sym] = CGI::unescape(value)
          h
        end
      else
        raise ArgumentError, "#{s} should be a Hash, a String or nil"
      end
    end
    private :convert_to_hash

    def convert_to_string(h)
      h.map do |key_value|
        key_value.map{ |val| CGI::escape(val.to_s) }.join("=")
      end.join("&")
    end
    private :convert_to_string

    def static
      param_list   = @options[:parameters].map{ |k, v| %(<param name="#{k}" value="#{v}"/>) }.join("\n")
      param_list  += %(\n<param name="flashvars" value="#{convert_to_string(@options[:flashvars])}"/>) unless @options[:flashvars].empty?
      html_options = @options[:html_options].map{ |k, v| %(#{k}="#{v}") }.join(" ")

      r = @view.javascript_tag(
        %(swfobject.registerObject("#{@options[:id]}_container", "#{@options[:flash_version]}", #{@options[:auto_install].to_json});)
      )
      r.safe_concat <<-"EOS".strip
        <div id="#{@options[:div_id]}">
          <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="#{@options[:width]}" height="#{@options[:height]}" id="#{@options[:id]}_container" #{html_options}>
            <param name="movie" value="#{@source}" />
            #{param_list}
            <!--[if !IE]>-->
            <object type="application/x-shockwave-flash" data="#{@source}" width="#{@options[:width]}" height="#{@options[:height]}" id="#{@options[:id]}">
            #{param_list}
            <!--<![endif]-->
            #{@options[:alt]}
            <!--[if !IE]>-->
            </object>
            <!--<![endif]-->
          </object>
        </div>
      EOS
      r << @view.javascript_tag(extend_js) if @options[:javascript_class]
      r.safe_concat library_check
      r
    end
    private :static

    def dynamic
      @options[:html_options] = @options[:html_options].merge(:id => @options[:id])
      @options[:parameters]   = @options[:parameters].dup # don't modify the original parameters

      args = (([@source] + @options.values_at(:div_id, :width, :height, :flash_version)).map(&:to_s) +
        @options.values_at(:auto_install, :flashvars, :parameters, :html_options)
      ).map(&:to_json).join(",")

      preamble = @options[:switch_off_auto_hide_show] ? "swfobject.switchOffAutoHideShow();" : ""

      r = @view.javascript_tag(preamble + "swfobject.embedSWF(#{args})")
      r.safe_concat <<-"EOS".strip
        <div id="#{@options[:div_id]}">
          #{@options[:alt]}
        </div>
      EOS

      r << @view.javascript_tag("swfobject.addDomLoadEvent(function(){#{extend_js}})") if @options[:javascript_class]
      r.safe_concat library_check
      r
    end
    private :dynamic

    def extend_js
      arglist = case
      when @options[:initialize].instance_of?(Array)
        @options[:initialize].map(&:to_json).join(",")
      when @options.has_key?(:initialize)
        @options[:initialize].to_json
      else
        ""
      end
      "Object.extend($('#{@options[:id]}'), #{@options[:javascript_class]}.prototype).initialize(#{arglist})"
    end
    private :extend_js

    def library_check
      return "" unless Rails.env.development?
      @view.javascript_tag(<<-"EOS")
      if(typeof swfobject == 'undefined') {
        document.getElementById('#{@options[:div_id]}').innerHTML = '<strong>Warning:</strong> SWFObject.js was not loaded properly. Make sure you <tt>&lt;%= javascript_include_tag :defaults %&gt;</tt> or <tt>&lt;%= javascript_include_tag :swfobject %&gt;</tt>';
      }
      EOS
    end
    private :library_check
  end
end