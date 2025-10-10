# 多系统支持 - 实施进度

## 📊 当前进度: 60%

### ✅ 已完成的修改

#### 1. 数据结构重构
- ✅ 将固定的 `freq1/spec1/freq2/spec2` 改为字典 `self.systems`
- ✅ 添加系统计数器和最大系统数量限制
- ✅ 初始化两个默认系统

#### 2. UI 组件更新
- ✅ 添加系统管理按钮 (+添加系统 / -删除系统)
- ✅ 动态系统标签页创建
- ✅ 动态绘图标签页创建

#### 3. 权重管理器
- ✅ 替换单滑块为多系统权重控件
- ✅ 每个系统独立的权重输入框
- ✅ 自动归一化功能

#### 4. 运行按钮
- ✅ 替换固定按钮为动态按钮
  - "运行当前系统"
  - "运行所有系统"
  - "重新处理当前"

#### 5. 辅助方法
- ✅ `_add_default_systems()` - 初始化默认系统
- ✅ `_create_system_tab()` - 创建系统标签页
- ✅ `add_new_system()` - 添加新系统
- ✅ `remove_current_system()` - 删除系统
- ✅ `_create_plot_tab()` - 创建绘图标签页
- ✅ `_update_weight_controls()` - 更新权重控件
- ✅ `on_system_weight_changed()` - 权重变化处理
- ✅ `on_auto_normalize_changed()` - 自动归一化处理
- ✅ `_normalize_weights()` - 权重归一化

### 🔧 待完成的修改

#### 6. 运行方法重构（关键！）
- ⏳ `run_current_system()` - 运行当前选中的系统
- ⏳ `run_all_systems()` - 顺序运行所有系统
- ⏳ `reprocess_current_system()` - 重新处理当前系统
- ⏳ 更新 `run_system()` 方法以支持系统名称而非数字
- ⏳ 更新 `parse_system()` 方法
- ⏳ 更新 `get_variable_values()` 方法
- ⏳ 更新 `on_j_input_mode_changed()` 方法
- ⏳ 更新 `generate_j_grid()` 方法

#### 7. 数据处理方法
- ⏳ 更新 `update_weighted_sum()` - 支持多系统加权
- ⏳ 更新 `plot_spectrum()` - 使用系统名称
- ⏳ 更新 `on_simulation_done()` - 处理任意系统完成
- ⏳ 更新 `on_reprocess_done()` - 处理任意系统重新处理

#### 8. 文件保存/加载
- ⏳ 更新 `save_parameters()` - 保存多系统
- ⏳ 更新 `load_parameters()` - 加载多系统
- ⏳ 更新 `export_spectrum()` - 导出多系统
- ⏳ 更新 `load_spectrum()` - 加载多系统

#### 9. 辅助方法更新
- ⏳ `_get_current_system_name()` - 获取当前系统名称
- ⏳ `_system_has_data()` - 检查系统是否有数据
- ⏳ `_all_systems_ready()` - 检查所有系统是否就绪

#### 10. 清理旧代码
- ⏳ 移除对 `self.freq1/freq2/spec1/spec2` 的所有引用
- ⏳ 移除对 `self.worker1/worker2` 的所有引用
- ⏳ 移除对 `self.plot1/plot2` 的所有引用

### 📝 需要注意的兼容性问题

1. **系统编号 vs 系统名称**
   - 旧代码使用数字 (1, 2)
   - 新代码使用字符串 ("System 1", "System 2")
   - 需要统一为系统名称

2. **绘图引用**
   - 旧: `self.plot1`, `self.plot2`
   - 新: `self.systems[sys_name]['plot_widget']`

3. **数据存储**
   - 旧: `self.freq1`, `self.spec1`
   - 新: `self.systems[sys_name]['freq']`, `self.systems[sys_name]['spec']`

### 🎯 下一步行动

1. **优先级 1**: 修改运行方法
   - `run_current_system()`
   - `run_all_systems()`
   - `reprocess_current_system()`

2. **优先级 2**: 更新所有 `parse_system()` 等方法

3. **优先级 3**: 更新 `update_weighted_sum()`

4. **优先级 4**: 清理旧代码引用

5. **优先级 5**: 测试和调试

### 预计剩余工作量
- 代码修改: 2-3 小时
- 测试调试: 1-2 小时
- 总计: 3-5 小时

---
**文档更新时间**: 2025-10-07  
**当前状态**: 进行中 (60% 完成)
