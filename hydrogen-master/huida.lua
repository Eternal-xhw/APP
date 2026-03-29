require "import"
import "mods.muk"
import "com.ua.*"

chrome = import "com.lua.LuaWebChrome"
client = import "com.lua.LuaWebViewclient"
callback = import "com.androlua.LuaWebView$LuaWebViewClient"


liulanurl,docode,ischeck=...

activity.setContentView(loadlayout("layout/huida"))

波纹({fh,_more},"圆主题")

liulan.loadUrl(liulanurl)



if docode~=nil then
  liulan.getSettings().setUserAgentString("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36")
   else
  liulan.getSettings().setUserAgentString("Mozilla/5.0 (Android 9; MI ) AppleWebKit/537.36 (KHTML) Version/4.0 Chrome/74.0.3729.136 mobile SearchCraft/2.8.2 baiduboxapp/3.2.5.10")--设置UA
end

liulan.removeView(liulan.getChildAt(0))

function setProgress(p)
  ValueAnimator.ofFloat({pbar.getWidth(),activity.getWidth()/100*p})
  .setDuration(500)
  .addUpdateListener{
    onAnimationUpdate=function(a)
      local x=a.getAnimatedValue()
      local linearParams = pbar.getLayoutParams()
      linearParams.width =x
      pbar.setLayoutParams(linearParams)
    end
  }.start()

end



liulan.setWebChromeClient(LuaWebChrome(LuaWebChrome.IWebChrine{
  onReceivedTitle=function(view, title)
    _title.text=(liulan.getTitle())
  end,
  onProgressChanged=function(view,p)
    setProgress(p)
    if p==100 then
      pbar.setVisibility(8)
      setProgress(0)
    end

  end,
}))


静态渐变(转0x(primaryc)-0x9f000000,转0x(primaryc),pbar,"横")


liulan.setWebViewClient{
  shouldOverrideUrlLoading=function(view,url)--回调参数，v控件，url网址
    local res=false    
    if url:sub(1,4)~="http" then
      双按钮对话框("提示","是否用第三方软件打开本链接？","是","否",
      function()
        xpcall(function()
          intent=Intent("android.intent.action.VIEW")
          intent.setData(Uri.parse(url))
          intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP)
          this.startActivity(intent)
          an.dismiss()       
        end,
        function(v)
          提示("尝试打开第三方app出错")
          an.dismiss()          
        end)
      end,
      function()       
        an.dismiss()
      end)
     else      
     if ischeck==nil then 检查链接(url)  else return false end
    end
    return true 
  end,
  onPageStarted=function(view,url,favicon)
    if docode then load(docode)(tostring(url)) end--登录判断
  end,
  onLoadResource=function(view,url)
    if 全局主题值=="Night" then
      加载js(view,[[(function(){var styleElem=null,doc=document,ie=doc.all,fontColor=50,sel="body,body *";styleElem=createCSS(sel,setStyle(fontColor),styleElem);function setStyle(fontColor){var colorArr=[fontColor,fontColor,fontColor];return"background-color:#]]..backgroundc:sub(4,#backgroundc)..[[ !important;color:RGB("+colorArr.join("%,")+"%) !important;"}function createCSS(sel,decl,styleElem){var doc=document,h=doc.getElementsByTagName("head")[0],styleElem=styleElem;if(!styleElem){s=doc.createElement("style");s.setAttribute("type","text/css");styleElem=ie?doc.styleSheets[doc.styleSheets.length-1]:h.appendChild(s)}if(ie){styleElem.addRule(sel,decl)}else{styleElem.innerHTML="";styleElem.appendChild(doc.createTextNode(sel+" {"+decl+"}"))}return styleElem}})();]])
    end  
    if docode then 屏蔽元素(view,{"SignFlowHomepage-footer"}) end
  end,
  onPageFinished=function(view,url)
    if 全局主题值=="Night" then
      加载js(view,[[(function(){var styleElem=null,doc=document,ie=doc.all,fontColor=50,sel="body,body *";styleElem=createCSS(sel,setStyle(fontColor),styleElem);function setStyle(fontColor){var colorArr=[fontColor,fontColor,fontColor];return"background-color:#]]..backgroundc:sub(4,#backgroundc)..[[ !important;color:RGB("+colorArr.join("%,")+"%) !important;"}function createCSS(sel,decl,styleElem){var doc=document,h=doc.getElementsByTagName("head")[0],styleElem=styleElem;if(!styleElem){s=doc.createElement("style");s.setAttribute("type","text/css");styleElem=ie?doc.styleSheets[doc.styleSheets.length-1]:h.appendChild(s)}if(ie){styleElem.addRule(sel,decl)}else{styleElem.innerHTML="";styleElem.appendChild(doc.createTextNode(sel+" {"+decl+"}"))}return styleElem}})();]])
    end
end}



liulan.getSettings()
.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN)
.setJavaScriptEnabled(true)--设置支持Js
--  .setSupportZoom(true)
 .setLoadWithOverviewMode(true)
--.setUseWideViewPort(true)
.setDefaultTextEncodingName("utf-8")
.setLoadsImagesAutomatically(true)
.setAllowFileAccess(false)
.setDatabasePath(APP_CACHEDIR)
--//设置 应用 缓存目录
.setAppCachePath(APP_CACHEDIR)
--//开启 DOM 存储功能
.setDomStorageEnabled(true)
--        //开启 数据库 存储功能
.setDatabaseEnabled(true)
--     //开启 应用缓存 功能
.setAppCacheEnabled(true)



a=MUKPopu({
  tittle="网页",
  list={
    {src=图标("refresh"),text="刷新",onClick=function()
        liulan.reload()
    end},--添加项目(菜单项)
    {src=图标("redo"),text="前进",onClick=function()
        liulan.goForward()
    end},--添加项目(菜单项)
    {src=图标("undo"),text="后退",onClick=function()
        liulan.goBack()
    end},--添加项目(菜单项)
    {src=图标("close"),text="停止",onClick=function()
        liulan.stopLoading()
    end},--添加项目(菜单项)

    {src=图标("share"),text="分享",onClick=function()
        复制文本(liulan.getUrl())
        提示("已复制网页链接到剪切板")
    end},

  }
})
