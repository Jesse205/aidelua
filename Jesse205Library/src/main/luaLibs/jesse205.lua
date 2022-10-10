local jesse205={}
_G.jesse205=jesse205
jesse205._VERSION="12.1.0 (Pro)"--库版本名
jesse205._VERSIONCODE=121099--库版本号
jesse205._ENV=_ENV
jesse205.themeType="Jesse205"--主题类型

require "import"--导入import
import "loadlayout2"


--惰性导入？
local fastImport={
  Bitmap="android.graphics.Bitmap",
  LayoutTransition="android.animation.LayoutTransition",
  StatService="com.baidu.mobstat.StatService",
  AppPath="com.jesse205.app.AppPath",
  PermissionUtil="com.jesse205.app.PermissionUtil",
  MyStyleUtil="com.jesse205.util.MyStyleUtil",
  MyToast="com.jesse205.util.MyToast",
  getNetErrorStr="com.jesse205.util.getNetErrorStr",
  MyAnimationUtil="com.jesse205.util.MyAnimationUtil",
  ScreenFixUtil="com.jesse205.util.ScreenFixUtil",
  --导入各种风格的控件
  StyleWidget="com.jesse205.widget.StyleWidget",
  MaterialButton_TextButton="com.jesse205.widget.StyleWidget",
  MaterialButton_OutlinedButton="com.jesse205.widget.StyleWidget",
  MaterialButton_TextButton_Normal="com.jesse205.widget.StyleWidget",
  MaterialButton_TextButton_Icon="com.jesse205.widget.StyleWidget",
  --导入各种布局表
  MyTextInputLayout="com.jesse205.layout.MyTextInputLayout",
}
local normalkeys={
  this=true,
  activity=true,
  application=true,
  resources=true,
  useCustomAppToolbar=true,
  decorView=true,
  darkNavigationBar=true,
  darkStatusBar=true,
  notLoadTheme=true,
  initApp=true,
  R=true,
  jesse205=true,
  _G=true,
  mainLay=true,
}
jesse205.normalkeys=normalkeys

local oldMetatable=getmetatable(_G)
local newMetatable={__index=function(self,key)
    if normalkeys[key] then
      return rawget(_G,key)
     else
      local value=fastImport[key]
      if value then
        import(value)
        return rawget(_G,key)
       else
        return oldMetatable.__index(self,key)
      end
    end
  end
}
setmetatable(_G,newMetatable)

local context=activity or service--当前context
jesse205.context=context
resources=context.getResources()--当前resources
--_G.resources=resources
R=luajava.bindClass(context.getPackageName()..".R")

if activity then
  window=activity.getWindow()
  notLoadTheme=notLoadTheme
  useCustomAppToolbar=useCustomAppToolbar
 else--没有activity不加载主题
  notLoadTheme=true
end

application=activity.getApplication()

--JavaAPI转LuaAPI
local activity2luaApi={
  "newActivity","getSupportActionBar",
  "getSharedData","setSharedData",
  "getString","getPackageName",
}
for index,content in ipairs(activity2luaApi) do
  _G[content]=function(...)
    return context[content](...)
  end
end
activity2luaApi=nil

import "android.os.Environment"
import "android.content.res.Configuration"

import "com.jesse205.lua.math"--导入更强大的math
import "com.jesse205.lua.string"--导入更强大的string
--import "com.jesse205.app.AppPath"--导入路径

if initApp then--初始化APP
  import "com.jesse205.app.initApp"
end

import "android.view.View"--加载主题要用
import "android.os.Build"

--加载主题
--在get某东西（ActionBar等）前必须把主题搞定
if not(notLoadTheme) then
  theme={
    color={
      Ripple={},
      Light={},
      Dark={},
      ActionBar={},
    },
    number={
      id={},
      Dimension={},
    },
    boolean={}
  }
  local colors,dimens
  local color=theme.color
  local ripple=color.Ripple
  local light=color.Light
  local dark=color.Dark
  local number=theme.number
  local dimension=number.Dimension

  setmetatable(color,{--普通颜色
    __index=function(self,key)
      local value=resources.getColor(R.color["jesse205_"..string.lower(key)])
      rawset(self,key,value)
      return value
    end
  })
  setmetatable(ripple,{--波纹颜色
    __index=function(self,key)
      local value=resources.getColor(R.color["jesse205_"..string.lower(key).."_Ripple"])
      rawset(self,key,value)
      return value
    end
  })
  setmetatable(light,{--偏亮颜色
    __index=function(self,key)
      local value=resources.getColor(R.color["jesse205_"..string.lower(key).."_Light"])
      rawset(self,key,value)
      return value
    end
  })
  setmetatable(dark,{--偏暗颜色
    __index=function(self,key)
      local value=resources.getColor(R.color["jesse205_"..string.lower(key).."_Dark"])
      rawset(self,key,value)
      return value
    end
  })
  setmetatable(number,{--数字
    __index=function(self,key)
      local value=resources.getInteger(R.integer["jesse205_"..string.lower(key)])
      rawset(self,key,value)
      return value
    end
  })
  setmetatable(dimension,{--数字
    __index=function(self,key)
      local value=resources.getDimension(R.dimen["jesse205_"..string.lower(key)])
      rawset(self,key,value)
      return value
    end
  })
  import "android.app.ActivityManager"
  import "com.jesse205.app.ThemeUtil"
  ThemeUtil.refreshUI()
end

--导入常用的包
import "androidx.appcompat.widget.*"
import "androidx.appcompat.app.*"

import "android.widget.*"
import "android.app.*"
import "android.os.*"
import "android.view.*"
import "android.view.inputmethod.InputMethodManager"

import "androidx.appcompat.app.AlertDialog"

import "android.widget.TextView"
import "android.widget.LinearLayout"
import "android.widget.FrameLayout"
import "android.widget.ScrollView"
import "androidx.appcompat.widget.AppCompatTextView"
import "androidx.appcompat.widget.AppCompatImageView"
import "androidx.appcompat.widget.LinearLayoutCompat"
import "androidx.coordinatorlayout.widget.CoordinatorLayout"

--导入常用类
import "android.graphics.Bitmap"
import "android.graphics.Color"
import "android.graphics.Typeface"
import "android.graphics.drawable.GradientDrawable"

import "androidx.core.app.ActivityCompat"
import "androidx.core.content.ContextCompat"
import "androidx.core.view.MenuItemCompat"

import "androidx.coordinatorlayout.widget.CoordinatorLayout"
import "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
import "androidx.cardview.widget.CardView"

import "com.jesse205.widget.MyRecyclerView"
import "androidx.recyclerview.widget.RecyclerView"
import "androidx.recyclerview.widget.StaggeredGridLayoutManager"
import "androidx.recyclerview.widget.LinearLayoutManager"

--import "android.animation.LayoutTransition"

import "android.net.Uri"
import "android.content.Intent"
import "android.content.Context"
import "android.content.res.ColorStateList"
import "android.content.pm.PackageManager"

--导入常用的Material类
import "com.google.android.material.appbar.AppBarLayout"
import "com.google.android.material.card.MaterialCardView"--卡片
import "com.google.android.material.button.MaterialButton"--按钮
import "com.google.android.material.snackbar.Snackbar"
import "com.google.android.material.textfield.TextInputEditText"--输入框
import "com.google.android.material.textfield.TextInputLayout"

--导入IO
import "java.io.File"
import "java.io.FileInputStream"
import "java.io.FileOutputStream"


import "com.lua.custrecycleradapter.AdapterCreator"--导入LuaCustRecyclerAdapter及相关类
import "com.lua.custrecycleradapter.LuaCustRecyclerAdapter"
import "com.lua.custrecycleradapter.LuaCustRecyclerHolder"

import "com.bumptech.glide.Glide"--导入Glide
--import "com.baidu.mobstat.StatService"--百度移动统计

inputMethodService=activity.getSystemService(Context.INPUT_METHOD_SERVICE)

--自动获取当地语言的对象
local phoneLanguage
function getLocalLangObj(zh,en)
  if not(phoneLanguage) then
    import "java.util.Locale"
    phoneLanguage = Locale.getDefault().getLanguage();
  end
  if phoneLanguage=="zh" then
    return zh or en
   else
    return en or zh
  end
end

--复制文字
function copyText(text)
  context.getSystemService(Context.CLIPBOARD_SERVICE).setText(text)
end

--通过id格式化字符串
function formatResStr(id,values)
  return String.format(context.getString(id),values)
end

--在浏览器打开链接
function openInBrowser(url)
  local viewIntent = Intent("android.intent.action.VIEW",Uri.parse(url))
  activity.startActivity(viewIntent)
end
openUrl=openInBrowser--通常情况下，应用不自带内置浏览器

--[[
相对路径转绝对路径

@param path 要转换的相对路径
@param localPath 相对的目录
]]
function rel2AbsPath(path,localPath)
  if path:find("^/") then
    return path
   else
    return localPath.."/"..path
  end
end

--将value转换为boolean类型
function toboolean(value)
  if value then
    return true
   else
    return false
  end
end

--进入Lua子页面
function newSubActivity(name,...)
  local nowDirFile=File(context.getLuaDir())
  local parentDirFile=nowDirFile.getParentFile()
  if nowDirFile.getName()=="sub" then
    newActivity(name,...)
   elseif parentDirFile.getName()=="sub" then
    if name:find("/") then
      newActivity(parentDirFile.getPath().."/"..name,...)
     else
      newActivity(parentDirFile.getPath().."/"..name.."/main.lua",...)
    end
   else
    newActivity("sub/"..name,...)
  end
end

function getColorStateList(id)
  return resources.getColorStateList(id)
end

--好用的加载中对话框
--[[
showLoadingDia：
@param message 信息
@param title 标题
@param cancelable 是否可以取消
]]
local loadingDia
function showLoadingDia(message,title,cancelable)
  if not(loadingDia) then
    import "android.app.ProgressDialog"
    loadingDia=ProgressDialog(context)
    loadingDia.setProgressStyle(ProgressDialog.STYLE_SPINNER)--进度条类型
    loadingDia.setTitle(title or context.getString(R.string.jesse205_loading))--标题
    loadingDia.setCancelable(cancelable or false)--是否可以取消
    loadingDia.setCanceledOnTouchOutside(cancelable or false)--是否可以点击外面取消
    loadingDia.setOnCancelListener{
      onCancel=function()
        loadingDia=nil--如果取消了，就把 loadingDia 赋值为空，视为没有正在展示的加载中对话框
    end}
    loadingDia.show()
  end
  loadingDia.setMessage(message or context.getString(R.string.jesse205_loading))
end
function closeLoadingDia()
  if loadingDia then
    loadingDia.dismiss()
    loadingDia=nil
  end
end
function getNowLoadingDia()
  return loadingDia
end

function showSimpleDialog(title,message)
  return AlertDialog.Builder(context)
  .setTitle(title)
  .setMessage(message)
  .setPositiveButton(android.R.string.ok,nil)
  .show()
end
showErrorDialog=showSimpleDialog

--自动初始化一个LayoutTransition
function newLayoutTransition()
  return LayoutTransition().enableTransitionType(LayoutTransition.CHANGING)
end

--以下为复写事件
function onError(title,message)
  showErrorDialog(tostring(title),tostring(message))
  pcall(function()
    io.open("/sdcard/Androlua/crash/"..activity.getPackageName()..".txt","a"):write(tostring(title)..os.date(" %Y-%m-%d %H:%M:%S").."\n"..tostring(message).."\n\n"):close()
  end)
  return true
end


--导入共享代码
require "AppSharedCode"

return jesse205