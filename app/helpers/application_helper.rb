# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def ga_code
    %^
      <script type="text/javascript">
      var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
      document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
      </script>
      <script type="text/javascript">
      try {
      var pageTracker = _gat._getTracker("UA-8379903-1");
      pageTracker._trackPageview();
      } catch(err) {}</script>
    ^
  end
end
