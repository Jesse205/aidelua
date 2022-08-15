--[[
FilesTabManager:文件标签管理器，顺便管理文件的读写与保存
FilesTabManager.openState; FilesTabManager.getopenState(): 文件打开状态
FilesTabManager.fileConfig; FilesTabManager.getFileConfig(): 现在打开的文件的配置
FilesTabManager.fileType; FilesTabManager.getFileType(): 现在打开的文件类型
FilesTabManager.openedFiles; FilesTabManager.getOpenedFiles(): 已打开的文件列表，以lowerPath作为键
  ┗ 数据格式:{
   ["/path1.lua"]={
     file=File(),
     path="/path1.lua",
     oldContent="content1",
     newContent="content2",
     lowerPath="/path1.lua",
     edited=true,
     }
   }
FilesTabManager.openFile(file,keepHistory): 打开文件
  ┣ file: 要打开的文件
  ┗ keepHistory:不删除新编辑器的历史记录
FilesTabManager.saveFile(): 保存当前编辑的文件
FilesTabManager.saveAllFiles(): 保存所有文件
]]
local FilesTabManager = {}
local openState, file, fileConfig,fileType = false, nil, nil, nil
local openedFiles = {}

function FilesTabManager.openFile(newFile,newFileType, keepHistory)
  file=newFile
  local filePath = file.getPath()
  local lowerFilePath = string.lower(filePath) -- 小写路径
  --local fileConfig
  fileConfig = openedFiles[lowerFilePath]
  if fileConfig == nil then
    fileConfig = {
      file = file,
      path = filePath,
      lowerPath = lowerFilePath
    }
    openedFiles[lowerFilePath] = fileConfig
  end

end

-- 保存当前打开的文件
function FilesTabManager.saveFile()
  if openState then
    if nowFileConfig.edited then
      local newContent = nowFileConfig.newContent
      io.open(nowFileConfig.path, "w"):write(newContent):close()
      nowFileConfig.oldContent = newContent -- 讲旧内容设置为新的内容
      return true -- 保存成功
    end
  end
end -- return:true，保存成功 nil，未保存 false，保存失败

-- 保存所有文件
function FilesTabManager.saveAllFiles()
end

-- 关闭文件，由于文件的打开都由Tab管理，所以不存在已有文件打开但是当前当前打开的文件为空的情况
function FilesTabManager.closeFile(lowerFilePath, saveFile)
  lowerFilePath = lowerFilePath or nowFileConfig.lowerFilePath
  openState = false
end

-- 保存所有文件
function FilesTabManager.closeAllFiles(saveFiles)
  for index, content in pairs(openedFiles) do
    FilesTabManager.closeFile(index, saveFiles)
  end
end

local function onFileTabLongClick(view)
  local tag = view.tag
  NowTabTouchTag = tag
  tag.onLongTouch = true
end

local moveCloseHeight
local function refreshMoveCloseHeight(height)
  height = height - 56
  if height <= 320 then
    moveCloseHeight = math.dp2int(height / 2)
   else
    moveCloseHeight = math.dp2int(160)
  end
end
FilesTabManager.refreshMoveCloseHeight = refreshMoveCloseHeight

local function onFileTabTouch(view, event)
  local tag = view.tag
  local action = event.getAction()
  -- print(action)
  -- local view=view
  if action == MotionEvent.ACTION_DOWN then
    tag.downY = event.getRawY()

   else
    if not (tag.onLongTouch) then
      return
    end
    local downY = tag.downY
    local moveY = event.getRawY() - downY
    if action == MotionEvent.ACTION_MOVE then
      -- print("test",tointeger(moveY),tointeger(event.getY()))
      if moveY > 0 and moveY < moveCloseHeight then
        view.setRotationX(moveY / moveCloseHeight * -90)
       elseif moveY >= moveCloseHeight then
        view.setRotationX(-90)
      end
     elseif action == MotionEvent.ACTION_UP then
      NowTabTouchTag = nil
      tag.onLongTouch = false
      if moveY > moveCloseHeight then
        closeFileAndTab(tag.tab)
        view.setRotationX(0)
        if OpenedFile then
          local tabConfig = FilesTabList[string.lower(NowFile.getPath())]
          if tabConfig then
            local tab = tabConfig.tab
            task(1, function()
              tab.select()
            end)
          end
        end
       else
        ObjectAnimator.ofFloat(view, "rotationX", {0}).setDuration(200)
        .setInterpolator(DecelerateInterpolator()).start()
      end
    end
  end
end

local function onFileTabLayTouch(view, event)
  local tag = NowTabTouchTag
  if tag == nil or not (tag.onLongTouch) then
    return
  end
  onFileTabTouch(tag.view, event)
  return true
end

local function initFileTabView(tab, tabTag)
  local view = tab.view
  tabTag.view = view
  view.setPadding(math.dp2int(8), math.dp2int(4), math.dp2int(8), math.dp2int(4))
  view.setGravity(Gravity.LEFT | Gravity.CENTER)
  view.tag = tabTag
  view.onTouch = onFileTabTouch
  view.onLongClick = onFileTabLongClick
  TooltipCompat.setTooltipText(view, tabTag.shortFilePath)
  local imageView = view.getChildAt(0)
  local textView = view.getChildAt(1)
  tabTag.imageView = imageView
  tabTag.textView = textView
  imageView.setPadding(math.dp2int(2), math.dp2int(2), math.dp2int(2), 0)
  textView.setAllCaps(false) -- 关闭全部大写
  .setTextSize(12)
end

-- 初始化 FilesTabManager
function FilesTabManager.init()
  filesTabLay.addOnTabSelectedListener(TabLayout.OnTabSelectedListener({
    onTabSelected = function(tab)
      local tag = tab.tag
      local file = tag.file
      --[[
    if (not(OpenedFile) or file.getPath()~=NowFile.getPath()) then
      openFile(file)
    end]]
    end,
    onTabReselected = function(tab)
      --[[
    if OpenedFile and IsEdtor then
      saveFile()
    end]]
    end,
    onTabUnselected = function(tab)
    end
  }))
  filesTabLay.onTouch = onFileTabLayTouch
end

function FilesTabManager.changeContent(content)
  nowFileConfig.newContent = content
end
function FilesTabManager.getFileConfig()
  return fileConfig
end
function FilesTabManager.getopenState()
  return openState
end
function FilesTabManager.getOpenedFiles()
  return openedFiles
end
function FilesTabManager.getFileType()
  return fileType
end

return createVirtualClass(FilesTabManager)
