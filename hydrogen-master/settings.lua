require "import"
import "android.widget.*"
import "android.view.*"
import "android.graphics.PorterDuffColorFilter"
import "android.graphics.PorterDuff"
import "mods.muk"
import "mods.loadlayout"
import "com.michael.NoScrollListView"
import "android.widget.NumberPicker$OnValueChangeListener"
设置视图("layout/settings")

波纹({fh},"圆主题")

about_item={
  {--标题
    LinearLayout;

    layout_width="fill";
    layout_height="-2";
    {
      TextView;
      Focusable=true;
      layout_marginTop="12dp";
      layout_marginBottom="12dp";
      gravity="center_vertical";
      Typeface=字体("product");
      id="title";
      textSize="15sp";
      textColor=primaryc;
      layout_marginLeft="16dp";
    };
  };

  {--图片,标题,简介
    LinearLayout;
    gravity="center";
    layout_width="fill";
    layout_height="64dp";
    {
      ImageView;
      layout_height="25dp";
      id="image";
      --padding="10dp";
      layout_width="25dp";
      layout_marginLeft="15dp";
      ColorFilter=textc;
    };
    {
      LinearLayout;
      orientation="vertical";
      layout_height="fill";
      gravity="center_vertical";
      layout_weight="1";
      {
        TextView;
        id="subtitle";
        textSize="16sp";
        textColor=textc;
        Typeface=字体("product");
        layout_marginLeft="16dp";
      };
      {
        TextView;
        textColor=stextc;
        id="message";
        textSize="14sp";

        Typeface=字体("product");
        layout_marginLeft="16dp";
      };
    };
  };

  {--图片,标题
    LinearLayout;
    layout_width="fill";
    layout_height="64dp";
    gravity="center_vertical";
    {
      ImageView;
      layout_height="25dp";
      id="image";
      --padding="10dp";
      layout_width="25dp";
      layout_marginLeft="15dp";
      ColorFilter=textc;
    };
    {
      TextView;
      id="subtitle";
      Typeface=字体("product");
      textSize="16sp";
      textColor=textc;
      layout_marginLeft="16dp";
    };
  };



  {--图片,标题,checkbox
    LinearLayout;
    gravity="center_vertical";
    layout_width="fill";
    layout_height="64dp";
    {
      ImageView;
      layout_height="25dp";
      id="image";
      --padding="10dp";
      layout_width="25dp";
      layout_marginLeft="15dp";
      ColorFilter=textc;
    };
    {
      TextView;
      id="subtitle";
      Typeface=字体("product");
      textSize="16sp";
      textColor=textc;
      gravity="center_vertical";
      layout_weight="1";
      layout_height="-1";
      layout_marginLeft="16dp";
    };
    {
      CheckBox;
      CheckBoxBackground=转0x(primaryc),
      id="status";
      focusable=false;
      clickable=false;
      layout_marginRight="16dp";
    };

  };

  {--图片 标题 描述 选框
    LinearLayout;
    gravity="center_vertical";
    layout_width="fill";
    layout_height="64dp";
    {
      ImageView;
      layout_height="25dp";
      id="image";
      --padding="10dp";
      layout_width="25dp";
      layout_marginLeft="15dp";
      ColorFilter=textc;
    };
    {
      LinearLayout;
      orientation="vertical";
      layout_height="fill";
      gravity="center_vertical";
      layout_weight="1";
      {
        TextView;
        id="subtitle";
        textSize="16sp";
        textColor=textc;
        Typeface=字体("product");
        layout_marginLeft="16dp";
      };

    };
    {
      NumberPicker;
      id="status";
      focusable=true;
      clickable=true;
      layout_marginRight="16dp";
    };
    {
      TextView;
      text="sp",
      textColor=textc,
      textSize="14sp",
      layout_marginRight="24dp";
    };

  };
};



if this.getSharedData("内部浏览器查看回答") == nil then
  this.setSharedData("内部浏览器查看回答","false")
end

--activity.setTheme(Theme_Material_Light)

data = {}
adp=LuaMultiAdapter(this,data,about_item)

adp.addAll{
  --{__type=1,title=""},
  {__type=4,subtitle="内部浏览器查看回答",image=图标(""),status={Checked=Boolean.valueOf(this.getSharedData("内部浏览器查看回答"))}},
  {__type=4,subtitle="自动打开剪贴板上的知乎链接",image=图标(""),status={Checked=Boolean.valueOf(this.getSharedData("自动打开剪贴板上的知乎链接"))}},
--  {__type=1,title=""},
  {__type=4,subtitle="夜间模式追随系统",image=图标(""),status={Checked=Boolean.valueOf(this.getSharedData("Setting_Auto_Night_Mode"))}},
  {__type=4,subtitle="夜间模式",image=图标(""),status={Checked=Boolean.valueOf(this.getSharedData("Setting_Night_Mode"))}},
--  {__type=1,title=""},
  {__type=4,subtitle="内部搜索(beta)",image=图标(""),status={Checked=Boolean.valueOf(this.getSharedData("内部搜索(beta)"))}},
  {__type=4,subtitle="回答预加载(beta)",image=图标(""),status={Checked=Boolean.valueOf(this.getSharedData("回答预加载(beta)"))}},
  {__type=5,subtitle="字体大小",image=图标(""),status={
      minValue=10,
      value=tonumber(activity.getSharedData("font_size")),
      maxValue=30,
      OnValueChangedListener=OnValueChangeListener{
        onValueChange=function(_,a)
          activity.setResult(1200,nil)

          activity.setSharedData("font_size",(a+1).."")
        end,
      },
      wrapSelectorWheel=false,
  }},
--  {__type=1,title=""},
  {__type=3,subtitle="清理缓存",image=图标("")},--,status={Checked=Boolean.valueOf(this.getSharedData("内部浏览器查看回答"))}}
  {__type=3,subtitle="关于",image=图标("")},
}

settings_list.setAdapter(adp)



function clear()
  task(function(dar)
    --   dar=File(activity.getLuaDir()).parent.."/cache/webviewCache"
    require "import"
    import "java.io.File"
    local tmp={[1]=0}

    local function getDirSize(tab,path)
      if File(path).exists() then
        local a=luajava.astable(File(path).listFiles() or {})

        for k,v in pairs(a) do
          if v.isDirectory() then
            getDirSize(tab,tostring(v))
           else

            tab[1]=tab[1]+v.length()
          end
        end
      end
    end
    getDirSize(tmp,dar)
    getDirSize(tmp,"/sdcard/Android/data/"..activity.getPackageName().."/cache/images")

    local a1,a2=File("/data/data/"..activity.getPackageName().."/database/webview.db"),File("/data/data/"..activity.getPackageName().."/database/webviewCache.db")
    pcall(function()
      tmp[1]=tmp[1]+(a1.length() or 0)+(a2.length() or 0)
      a1.delete()
      a2.delete()
    end)
    LuaUtil.rmDir(File(dar))
    LuaUtil.rmDir(File("/sdcard/Android/data/"..activity.getPackageName().."/cache/images"))

    return tmp[1]
    end,APP_CACHEDIR,function(m)

    提示("清理成功,共清理 "..tokb(m))
  end)
end


settab={
  ["夜间模式"]="Setting_Night_Mode",
  ["夜间模式追随系统"]="Setting_Auto_Night_Mode",
}--设置数据

settings_list.setOnItemClickListener(AdapterView.OnItemClickListener{
  onItemClick=function(id,v,zero,one)
    if v.Tag.status ~= nil then

      if v.Tag.status.Checked then
        this.setSharedData(settab[tostring(v.Tag.subtitle.Text)] or v.Tag.subtitle.Text,"false")
        data[one].status["Checked"]=false
       else
        this.setSharedData(settab[tostring(v.Tag.subtitle.Text)] or v.Tag.subtitle.Text,"true")
        data[one].status["Checked"]=true
      end

    end




    local tab={ --点击table
      ["回答预加载(beta)"]=function()
        提示("此功能可能还有隐性bug,仅供体验，若影响体验请关闭")
      end,
      夜间模式=function()
        提示("返回主页面生效")
        activity.setResult(1200,nil)
      end,
      夜间模式追随系统=function(self)
        self.夜间模式()
      end,
      字体大小=function()
        activity.setResult(1200,nil)
      end,
      关于=function()
        activity.newActivity("about")
      end,
      清理缓存=function()
        clear()
      end,
    }
    (tab[tostring(v.Tag.subtitle.Text)] or function()end) (tab)
    adp.notifyDataSetChanged()--更新列表
end})