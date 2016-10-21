
use strict;				#严格语法;
use warnings;			#错误提示;
use File::Basename;		#路径操作;
use Cwd;				#路径操作;
my $percent;			#百分比;
my $rate_st=0;			#进度条计数;
my $rate_su=0;			#进度条总数;
#------------------以下为非系统或结构变量----------------#
my $raw_head;		#原始数据表头所在行;
my $run_head;		#处理后数据表头所在行;
my $match;			#精确匹配T/模糊匹配F;
my $temp;			#缓存;
my @temp_split;		#缓存;
my @raw_data;		#原始数据;
my @raw_data_split="";	#行数据;
my @run_data;		#处理后数据;
my @run_data_split="";	#行数据;
my @raw_header;		#表头处理;
my @run_header;		#表头处理;
my %Search;			#共有表头构建哈希;
my $raw_index;		#数组下标;
my $run_index;		#数组下标;
my $raw_line;		#读取数据;
my $run_line;		#读取数据;
my $local=0;			#相对定位坐标;
my $flag;			#开关变量;
my $keys;			#哈希键;
my $index=0;			#临时下标;
my $error;				#是否错行;
#------------------------路径操作------------------------#
my $OS= $^O;
my $Script_Start=time;
my $cwd;					#路径变量;
if ($0 =~ m{^/}) {			#根据系统获得当前目录地址;
  $cwd = dirname($0);
} else {
  $cwd = dirname(getcwd()."/$0");
}
my $path=$cwd;				#目录路径;
$path=~s/\\/\\\\/g;			#根据系统选择斜杠和反斜杠;

#----------------------脚本重构区域----------------------#

$rate_su=0;					#更新进度条;
opendir(DIR,"$path");
while(my $file = readdir(DIR))				#遍历目录下文件;
{ 
	if($file=~/_output\.txt/){
		$rate_su+=1;
	}
}
opendir(DIR,"$path");		#打开当前目录;
system("cls");
print "System Info:$OS\nSystem Time:$Script_Start\n";
do{
	print "\nPlease Input <raw_head>,<run_head> as '1,4'\n";	#提示语;
	$temp=<STDIN>;								#等待输入;
	chomp($temp);
	@temp_split=split /\,/,$temp;				#分割;
	$raw_head=$temp_split[0];					#获得原始数据表头;
	$run_head=$temp_split[1];					#获得处理后数据表头;
}while(!(($raw_head=~/\d+/)&&($run_head=~/\d+/)));
print "\nraw_head:$raw_head\nrun_head:$run_head\n---------->Run\n\n";
open ERR,'>','Err.txt';
while(my $file = readdir(DIR))				#遍历目录下文件;
{ 
		if($file=~/_new\.txt/){						#原始数据;
			my $run_file=$file;							#处理后数据;
			$run_file=~s/_new.txt/_old\.txt/;	
			open RAW,'<',"$file";						#打开句柄，获得数据;
			@raw_data=<RAW>;
			close RAW;
			open RUN,'<',"$run_file";						#打开句柄，获得数据;
			@run_data=<RUN>;
			close RUN;
			@raw_header=split /\t/,"$raw_data[$raw_head-1]";	#获得表头字段;
			@run_header=split /\t/,"$run_data[$run_head-1]";	#获得表头字段;
			$raw_index=-1;								#下标初始化;
			my $Count=0;
			foreach $raw_line(@raw_header){				#表头比对,确定同一字段在两者中的位置;
				chomp($raw_line);
				$raw_index+=1;
				$run_index=-1;
				foreach $run_line(@run_header){
					chomp($run_line);
					$run_index+=1;
					if($raw_line eq $run_line){
						$Count+=1;
						$temp=$raw_index.";".$run_index;		#构建哈希键;
						$Search{$raw_line}=$temp;
						last;
					}
				}
			}
			if($Count==0){
				print "$file\tCan't Find Common Header\n";
				next;
			}
#----------------------------字段调整---------------------------;			
			print "$file\tCommon Header Count:$Count\n";
			$index=-1;							#初始化坐标;
			$error="False";
			foreach $raw_line(@raw_data){				#内容比对;
				$raw_line=~s/\s//;
				chomp($raw_line);
				$index+=1;
				if($index>=$raw_head){									#获得主体内容;
					@raw_data_split=split /\t/,$raw_line;
					my $run_index=$index+$local-1;						#对其下标;
					@run_data_split=split /\t/,$run_data[$run_index];
					$flag="True";
					foreach $keys(sort keys %Search){	#遍历哈希表;
						$temp=$Search{$keys};
						@temp_split=split /;/,"$temp";
						$temp=$keys;
						$raw_index=$temp_split[0];
						$run_index=$temp_split[1];			#获得表头绝对位置;
						if($raw_data_split[$raw_index] && $run_data_split[$run_index]){
							chomp($raw_data_split[$raw_index]);
							chomp($run_data_split[$run_index]);
							if($raw_data_split[$raw_index] eq $run_data_split[$run_index]){
								$flag="True";
							}else{
								$flag="False";
							}
						}else{
							$flag="True";
						}
						if($flag eq "False"){					#存在差异;
							print ERR"$file\tError:\[Line $index\]$keys:$temp\[$raw_index;$run_index]\n";
							print "$file\tError:\[Line $index\]$keys:$temp\[$raw_index;$run_index]\n";
							if($raw_data_split[$raw_index] && $run_data_split[$run_index]){
								print ERR"$raw_data_split[$raw_index]\t$run_data_split[$run_index]\n";
								print "$raw_data_split[$raw_index]\t$run_data_split[$run_index]\n";
							}
						}
					}
				}
			}
			$rate_st+=1;
			my $k=&proc_bar($rate_st,$rate_su)*100;
			print "------------------------------------------------------------------------$k\%\n";
		}
		
}
close ERR;
#----------------------脚本持续时间----------------------#
my $Duration = (time - $Script_Start)/60;
printf("\nThis Perl Script Has Been Running For %0.2f Minute\n",$Duration);

#----------------------子函数声明------------------------#
sub proc_bar{				#进度条百分比显示函数;
        my $i = $_[0] || return 0;
        my $n = $_[1] || return 0;
		my $k=$i/$n;
		return $k;
}
