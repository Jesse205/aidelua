return {
  {
    name="Lua 活动 (Activity)",--有enName时就是中文名，没enName时就是英文名
    enName="Lua Activity",--英文名
    id="luaactivity",--标识
    fileExtension="lua",--扩展名
    --在 v5.1.0(51099) 改名为 content
    content=[[require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

--activity.setTitle("{{ModuleName}}")
activity.setTheme(R.style.AppTheme)
activity.setContentView(loadlayout("layout"))
actionBar=activity.getActionBar()
actionBar.setDisplayHomeAsUpEnabled(true) 

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

]],
  },

  {
    name="Lua 活动 (Activity)（AndroidX）",
    enName="Lua Activity (AndroidX)",
    id="luaactivity_android",
    fileExtension="lua",
    enabledVar="oldAndroidXSupport",
    content=[[require "import"
--import "androidx"
import "androidx.appcompat.app.*"
import "androidx.appcompat.view.*"
import "androidx.appcompat.widget.*"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

import "androidx.coordinatorlayout.widget.CoordinatorLayout"

--activity.setTitle("{{ModuleName}}")
--activity.setTheme(R.style.AppTheme)
activity.setContentView(loadlayout("layout"))
actionBar=activity.getSupportActionBar()
actionBar.setDisplayHomeAsUpEnabled(true) 

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

]],
  },

  {
    name="Lua 活动 (Activity)（Jesse205）",
    enName="Lua Activity (Jesse205)",
    id="luaactivity_jesse205",
    fileExtension="lua",
    enabledVar="oldJesse205Support",
    content=[[require "import"
import "jesse205"

activity.setTitle(R.string.app_name)
activity.setContentView(loadlayout2("layout"))
actionBar.setDisplayHomeAsUpEnabled(true) 

function onOptionsItemSelected(item)
  local id=item.getItemId()
  if id==android.R.id.home then
    activity.finish()
  end
end

function onConfigurationChanged(config)
  screenConfigDecoder:decodeConfiguration(config)
end


screenConfigDecoder=ScreenFixUtil.ScreenConfigDecoder({
  
})

onConfigurationChanged(resources.getConfiguration())

]],
  },

  {
    name="Lua 布局 (Layout)",
    enName="Lua Layout",
    id="lualayout",
    fileExtension="aly",
    content=[[{
  LinearLayout;
  layout_height="fill";
  layout_width="fill";
  orientation="vertical";
  {
    TextView;
    gravity="center";
    text="Hello World";
    layout_height="fill";
    layout_width="fill";
  };
}]],
  },

  {
    name="Lua 布局 (Layout)（AndroidX）",
    enName="Lua Layout (AndroidX)",
    d="lualayout_androidx",
    fileExtension="aly",
    enabledVar="oldAndroidXSupport",
    content=[[{
  CoordinatorLayout;
  layout_height="fill";
  layout_width="fill";
  id="mainLay";
  {
    TextView;
    gravity="center";
    text="Hello World";
    layout_height="fill";
    layout_width="fill";
  };
}]],
  },

  {
    name="Lua 表 (Table)",
    enName="Lua Table",
    id="luatable",
    fileExtension="aly",
    content=[[{
  
}]],
  },

  {
    name="Lua 模块 (Module)",
    enName="Lua Module",
    id="luamodule",
    fileExtension="lua",
    content=[[local {{ShoredModuleName}}={}
setmetatable({{ShoredModuleName}},{{ShoredModuleName}})
local metatable={__index={{ShoredModuleName}}}

function {{ShoredModuleName}}.__call(self)
  local self={}
  setmetatable(self,metatable)
  return self
end
return {{ShoredModuleName}}
]],
  },

  {
    name="空 Lua 文件",
    enName="Empty Lua File",
    id="emptyfile_lua",
    fileExtension="lua",
    content="",
  },

  {
    name="空文件",
    enName="Empty File",
    id="emptyfile",
    fileExtension="txt",
    content="",
  },

}