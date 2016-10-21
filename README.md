# CNV_Analysis
#						Function:Script_Run_Check_Con V1.0
#						Author:张强
#						Date:2016-10-13
#						Version:1.0
#脚本功能：核查注释类脚本运行后原始文件与处理后结果是否一致
#
#使用方法：<需求文件>文件1new,
#					 文件2old,
#					 Script_Run_Check_Con脚本;
#
#		   <使用过程>设定文件new表头所在行$raw_head，
#					 设定文件old表头所在行$run_head,
#					 设定匹配模式$match<精确匹配/模糊匹配>,
#					 运行脚本;
#
#		   <命令语句>cd->Perl->$raw_head,$run_head,$match->Run；
#
#输出文件:界面输出结果有误数据编号;
#
#注意事项: 同样文件请不要运行两次脚本，如果第一次运行时原始数据有空行，
#		   再次运行会报错
#		   代码调试/优化请更新日志，如下所示“调试/优化/内容” --Author
