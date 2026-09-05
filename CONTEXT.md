# Wrong Question Notebook (WQN)

WQN 是一个帮助学生记录、整理和复习错题的 Web 应用。它将纸质错题本变成一套由笔记本、题目、复习会话与 AI 辅助洞察组成的交互式系统。

## 语言

### 核心对象

**Notebook（笔记本）**：
一组带颜色和图标标识的集合，按科目（数学、物理……）组织学生的题目。
_避免_：Subject（科目）——产品已改用「notebook」；「subject」仅作为代码、数据库及部分 UI 文案中的遗留名称保留。

**Notebook Shelf（笔记本书架）**：
学生的首页视图，展示其所有笔记本，每本附带题目数量与待复习摘要。
_避免_：Dashboard、subject list（科目列表）。

**Problem（题目）**：
学生练习或做错的单道已记录题目，包含内容、类型、掌握状态，以及可选的答案配置与解答。
_避免_：Question、exercise（当指代已保存的记录时）。

**Problem Type（题目类型）**：
题目的种类——选择题（MCQ）、简答题或问答题。
_避免_：Q-type、question kind。

**Tag（标签）**：
作用域限定在笔记本内的关键词标签，附着在题目上用于细粒度分类与过滤。

**Answer Configuration（答案配置）**：
题目正确答案的表达方式——一个选项（MCQ）、一组可接受的简短文本，或一个带容差及可选单位的数值。
_避免_：Correct answer（当你指的是配置而非已保存的值时）。

**Mastery Status（掌握状态）**：
题目的生命周期状态：Wrong（错误）→ Needs Review（待复习）→ Mastered（已掌握）。
_避免_：Status、progress（单独使用两者均有歧义）。

**Attempt（作答记录）**：
单次提交的答案及其结果，若是自我评估，还包括学生自己对作答情况的主观判断。
_避免_：Submission、response（当指代已保存的记录时）。

**Error Cause（错误原因）**：
学生做错题目的原因——概念性理解错误、步骤性错误、知识盲区、审题不清、粗心失误、时间不足或答案不完整。
_避免_：Reason、mistake type、category。

### 复习

**Review Session（复习会话）**：
一次结构化、可暂停的题目演练过程，期间学生提交作答。会话分为 Normal（常规）、Spaced Repetition（间隔重复）或 Insights Review（洞察复习）。
_避免_：Practice mode（练习模式是不计入记录的预览变体，不属于会话）。

**Spaced Repetition（间隔重复）**：
根据作答情况，以递增间隔安排每道题下次复习时间的调度方式，使到期题目在正确的时间点重现。
_避免_：SRS（仅内部使用）、revision plan。

**Insights Review（洞察复习）**：
根据学生已识别的薄弱点组装而成的复习会话，用于针对特定错误模式。
_避免_：Smart review、weakness drill。

### 分享与社区

**Problem Set（题集）**：
一组为集中复习而组装并命名的题目集合，可与他人分享。
_避免_：Set、deck（单独使用时均有歧义）。

**Manual Set（手动题集）**：
成员逐题手动挑选的题集。

**Smart Set（智能题集）**：
成员根据已保存的筛选条件自动填充、而非手动挑选的题集。
_避免_：Auto set、dynamic set。

**Filter Criteria（筛选条件）**：
一种可复用的规范（标签、状态、题目类型、复习日期范围），用于驱动分面搜索、智能题集及智能题集的成员资格。
_避免_：Smart filter、query（单独使用）。

**Sharing Level（分享级别）**：
题集的公开方式——Private（私密）、Limited（按邮箱与特定人员分享）或 Public（任何有链接者可见）。
_避免_：Visibility（保留给已上架/未上架切换开关）。

**Listed（已上架）**：
公开题集选择进入 Discovery（发现）并附带科目分类的状态。公开题集可以是未上架的（仅直接链接可见），而已上架的题集一定是公开的。
_避免_：Published、discoverable。

**Discovery（发现）**：
学生搜索、过滤和排序其他学生上架题集的公开浏览界面。
_避免_：Explore、gallery。

**Creator（创作者）**：
上架公开题集的学生，因此拥有带其互动统计与已上架题集的公开主页。

**Engagement（互动）**：
已上架题集上的公开社交信号——浏览量（已过滤跳出）、点赞、收藏、复制和举报。收藏是学生自己的保存；点赞是公开的赞赏。
_避免_：Metrics、stats（当指代每个题集的信号时）。

### AI 辅助

**AI Extraction（AI 提取）**：
将题目照片转换为结构化的题目草稿——识别其类型、选项和可能的答案——由学生在保存前审阅。
_避免_：OCR、scanning（提取包含结构，而不只是文本）。

**Insight Digest（洞察摘要）**：
根据学生的作答记录与错误原因，由 AI 周期性生成的错误模式、薄弱点与知识点聚类报告。
_避免_：Insights（单独复数）、report（泛指）。

### 会话持久性

**Remembered Login（记住登录）**：
勾选「记住我」后登录产生的会话，其凭据在浏览器重启后依然保留，用户下次无需重新输入账号密码。
_避免_：Remember me（保留为表单标签文案）、persistent session。

**Transient Login（临时登录）**：
未勾选「记住我」登录产生的会话，浏览器关闭后即清除，下次访问需重新登录。邮箱验证/密码重置链接产生的会话默认为临时登录。
_避免_：guest session、anonymous。

### 传输

**QR Transfer（二维码传输）**：
通过扫描二维码将题目照片从学生手机传入短时会话，进而传到桌面，图片可在该会话中保存或提取。
_避免_：Upload link、phone sync。
