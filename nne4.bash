# E04
#  3つのネームスペース(仮想PC) ns1,ns2,ns3を作成し、ブリッジ(仮想ネットワーク
#  スイッチ)br1を作成する。それぞれに仮想イーサネットインタフェースを設定し
#  IPアドレスを追加する。n1->n2, n2->n3, n3->n1へとpingコマンドでネットワーク
#  の疎通を確認する。ns1,ns2,n3は同一セグメントに所属する。セグメントとはLAN
#  のことである。同一セグメント内に所属するPC同士はルーターが無くても互いに
#  通信することができる。逆に同一セグメントに所属しない場合はルーターが無いと
#  通信することができない。

#状態(status): 
# 0:初期状態
# 1:ネットワークネームスペース(ns1,ns2,n3)を作成した状態
# 2:ブリッジ(br1)を作成した状態
# 3:仮想ネットワークインタフェースns1-veth0,ns2-veth0,ns3-veth0,br1-veth0,br1-veth1,br1-veth2を作成した状態
# 4:仮想ネットワークインタフェースをns1,ns2,ns3に配置した状態
# 5:仮想ネットワークインタフェースをbr1に配置した状態
# 6:仮想ネットワークインタフェースにIPアドレスを設定した状態
# 7:ネットワークネームスペースの仮想ネットワークインタフェースを有効(UP)にした状態
# 8:ブリッジとブリッジの仮想ネットワークインタフェースを有効(UP)にした状態
# 9:ネットワークネームスペースのループバックデバイスを有効にした状態

if [  -e ./.namespace_tmp ]
then
	stat=$(cat ./.namespace_tmp)
else
	stat=0    
fi

function fn_fig1() {
cat << END
#
#     +----------------+ 
#     |                | 
# ns1 |                |
#     |                |
#     +----------------+
#     +----------------+
#     |                |
# ns2 |                | 
#     |                |
#     +----------------+
#     +----------------+
#     |                |
# ns3 |                |
#     |                |
#     +----------------+
#

END
}

function fn_exp1() {
cat << END
# ネットワークネームスペースを3つ作成します。ns1,ns2,nS3はホストOSのLinuxからは
# ネットワーク的に独立しています。ここではns1,ns2,ns3を仮想PCとして扱います。
# 
# sudo ip netns add ns1
# sudo ip netns add ns2
# sudo ip netns add ns3
#
# 「sudo 管理者コマンド」は、管理者権限が無いと実行できないコマンドを特別に許可さ
#  れたユーザーが実行できるようにするためのコマンドです。ipコマンドの一部の機能を
#  実行するには管理者権限が必要です。
#
# 「ip netns」コマンドはネットワークネームスペース関連の設定をするコマンドです。
# 「ip netns add ネットワークネームスペース名」は、ネットワークネームスペースを
#  作成します。作成したネットワークネームスペースは「ip netns list」コマンドで
#  確認できます(メニュー 6.ネットワークネームスペースを確認)。

END
}

function fn_fig2() {
cat << END
#
#                                br1
#     +----------------+    +-----------+
#     |                |    |           |
# ns1 |                |    |           |
#     |                |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |                |    |           |
# ns2 |                |    |           |
#     |                |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |                |    |           |
# ns3 |                |    |           |
#     |                |    |           |
#     +----------------+    +-----------+
#
END
}

function fn_exp2() {
cat << END
# ブリッジ(br1)を作成します。ブリッジは仮想ネットワークスイッチであり、実際
# のネットワークデバイスと仮想ネットワークデバイスを接続することができます。
# ここでは仮想PC同士を接続するスイッチングハブの機能を実現しています。
#
# sudo ip link add br1 type bridge
#
#「ip link」コマンドはネットワークネームスペース関連の設定をするコマンドです。
#「ip link add ブリッジ名 type bridge」は、ブリッジを 作成します。作成した
# ブリッジは「ip link list」コマンドで確認できます(メニュー x.ブリッジを確認)。

END
}

function fn_fig3() {
cat << END
#
#                                                        br1 
#     +----------------+                            +-----------+
#     |                |                            |           |
# ns1 |                | ns1-veth0 o----o br1-veth0 |           | 
#     |                |                            |           |
#     +----------------+                            |           |
#     +----------------+                            |           |
#     |                |                            |           |
# ns2 |                | ns2-veth0 o----o br1-veth1 |           |
#     |                |                            |           |
#     +----------------+                            |           |
#     +----------------+                            |           |
#     |                |                            |           |
# ns3 |                | ns3-veth0 o----o br1-veth2 |           | 
#     |                |                            |           |
#     +----------------+                            +-----------+
#

END
}

function fn_exp3() {
cat << END
# 仮想ネットワークインタフェース(NIC)と仮想ネットワークケーブルを作成する。
#
# sudo ip link add ns1-veth0 type veth peer name br1-veth0
# sudo ip link add ns2-veth0 type veth peer name br1-veth1
# sudo ip link add ns3-veth0 type veth peer name br1-veth2
#
# ns1-veth0とbr1-veth0 が1つ目のセットで、
# ns2-veth0とbr1-veth1 が2つ目のセットで、
# ns3-veth0とbr1-veth2 が3つ目のセットである。

# イメージとしては両端に仮想NICが接続されたネットワークケーブルを作成した状態
# である。ここでは仮想ネットワークインタフェースはまだネットワークネームスペース
# に配置されていない。
#
# 「ip link」コマンドは、ネットワークインタフェース関連の設定をするコマンド。
#   add NIC名       :仮想ネットワークインタフェース名を追加する。
#   type タイプ     :タイプのvethは仮想イーサネット(virtual ethernet)を指定する。
#   peer name NIC名 :ペアとなる仮想ネットワークインタフェース名を指定する。

END
}

function fn_fig4() {
cat << END
#
#                                            br1
#     +----------------+                +-----------+
#     |        DOWN    |                |           |
# ns1 |      ns1-veth0 o----o br1-veth0 |           |
#     |                |                |           |
#     +----------------+                |           |
#     +----------------+                |           |
#     |        DOWN    |                |           |
# ns2 |      ns2-veth0 o----o br1-veth1 |           |
#     |                |                |           |
#     +----------------+                |           |
#     +----------------+                |           |
#     |         DOWN   |                |           |
# ns3 |      ns3-veth0 o----o br1-veth2 |           |
#     |                |                |           |
#     +----------------+                +-----------+
#
END
}

function fn_exp4() {
cat << END
# 仮想ネットワークインタフェースをネットワークネームスペースに配置する。
# ブリッジ側にはまだ接続されていない。また、仮想ネットワークインタフェース
# は無効(DOWN)な状態である。よってまだ通信はできない。
#
# sudo ip link set ns1-veth0 netns ns1
# sudo ip link set ns2-veth0 netns ns2
# sudo ip link set ns3-veth0 netns ns3
#
# 「ip link set 仮想NIC名 netns ネットワークネームスペース名 」コマンドは、
# は仮想ネットワークインタフェースをネットワークネームスペースに配置する。 

END
}

function fn_fig5() {
cat << END
#
#                             br1 DOWN
#     +----------------+    +-----------+
#     |         DOWN   |    |   DOWN    |
# ns1 |      ns1-veth0 o----o br1-veth0 |
#     |                |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |         DOWN   |    |   DOWN    |
# ns2 |      ns2-veth0 o----o br1-veth1 |
#     |                |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |        DOWN    |    |   DOWN    |
# ns3 |      ns3-veth0 o----o br1-veth2 |
#     |                |    |           |
#     +----------------+    +-----------+
#

END
}

function fn_exp5() {
cat << END
# 仮想ネットワークインタフェースをブリッジに配置する。インタフェースのmasterを
# br1にすることでブリッジに追加することができる。インタフェースは無効(DOWN)な
# 状態である。よってまだ通信はできない。
#
# sudo ip link set dev br1-veth0 master br1
# sudo ip link set dev br1-veth1 master br1
# sudo ip link set dev br1-veth2 master br1
#
#「ip link set dev 仮想NIC名 master ブリッジ名 」コマンドは、
# 仮想ネットワークインタフェースをブリッジに配置する。 

END
}

function fn_fig6() {
cat << END
#
#            [192.0.2.0/24]
#                             br1 DOWN
#     +----------------+    +-----------+
#     |        DOWN    |    |   DOWN    |
# ns1 |      ns1-veth0 o----o br1-veth0 |
#     |   192.0.2.1/24 |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |        DOWN    |    |   DOWN    |
# ns2 |      ns2-veth0 o----o br1-veth1 |
#     |   192.0.2.2/24 |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |        DOWN    |    |   DOWN    |
# ns3 |      ns3-veth0 o----o br1-veth2 |
#     |   192.0.2.3/24 |    |           |
#     +----------------+    +-----------+
#

END
}

function fn_exp6() {
cat << END
# 仮想ネットワークインタフェースにIPアドレスを設定する。
#
# sudo ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0 
# sudo ip netns exec ns2 ip address add 192.0.2.2/24 dev ns2-veth0 
# sudo ip netns exec ns3 ip address add 192.0.2.3/24 dev ns3-veth0 
#
# 「ip netns exec」コマンドはネットワークネームスペース内でコマンドを実行する
# ためのコマンドです。ns1,ns2,ns3はネットワーク的に独立しているために、ns1内に
# あるns1-veth0にIPアドレスを設定するためには、ns1の内部でip addressコマンド
# を実行する必要があります。
# 「ip address」コマンドはIPアドレスを表示したり、IPアドレスを設定したりします。
# 「ip address add IPアドレス dev ネットワークインタフェース」は、IPアドレスを
# ネットワークインタフェースに設定します。 
# まだ仮想ネットワークインタフェースは無効(DOWN)な状態です。
# 

END
}

function fn_fig7() {
cat << END
#
#            [192.0.2.0/24]
#                             br1 DOWN  
#     +----------------+    +-----------+
#     |         UP     |    |   DOWN    |
# ns1 |      ns1-veth0 O----o br1-veth0 |
#     |   192.0.2.1/24 |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |         UP     |    |   DOWN    |
# ns2 |      ns2-veth0 O----o br1-veth1 |
#     |   192.0.2.2/24 |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |         UP     |    |   DOWN    |
# ns3 |      ns3-veth0 O----o br1-veth2 |
#     |   192.0.2.3/24 |    |           |
#     +----------------+    +-----------+
#

END
}

function fn_exp7() {
cat << END
# ネットワークネームスペースの仮想ネットワークインタフェースを有効化(UP)します。
#
# sudo ip netns exec ns1 ip link set ns1-veth0 up
# sudo ip netns exec ns2 ip link set ns2-veth0 up
# sudo ip netns exec ns3 ip link set ns3-veth0 up
#
# 「ip link set <device> up」コマンドはネットワークインタフェースを有効化 
# (UP)します。
#

END
}

function fn_fig8() {
cat << END
#
#            [192.0.2.0/24]
#                              br1 UP  
#     +----------------+    +-----------+
#     |         UP     |    |    UP     |
# ns1 |      ns1-veth0 O----O br1-veth0 |
#     |   192.0.2.1/24 |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |         UP     |    |    UP     |
# ns2 |      ns2-veth0 O----O br1-veth1 |
#     |   192.0.2.2/24 |    |           |
#     +----------------+    |           |
#     +----------------+    |           |
#     |         UP     |    |    UP     |
# ns3 |      ns3-veth0 O----O br1-veth2 |
#     |   192.0.2.3/24 |    |           |
#     +----------------+    +-----------+
#

END
}

function fn_exp8() {
cat << END
# ブリッジとブリッジの仮想ネットワークインタフェースを有効化(UP)します。
#
# sudo ip link set br1-veth0 up
# sudo ip link set br1-veth1 up
# sudo ip link set br1-veth2 up
# sudo ip link set br1 up
#
# 「ip link set <device> up」コマンドはネットワークインタフェースを有効化 
# (UP)します。
#

END
}

function fn_fig() {
    echo ''
	case $stat in
		0) echo 'ネットワークネームスペースがありません' ;;
		1) echo '状態(1)'
           fn_fig1 
           ;;
		2) echo '状態(2)'
           fn_fig2
           ;;
		3) echo '状態(3)'
           fn_fig3
           ;;
		4) echo '状態(4)'
           fn_fig4
           ;;
		5) echo '状態(5)'
           fn_fig5
           ;;
		6) echo '状態(6)'
           fn_fig6
           ;;
		7) echo '状態(7)'
           fn_fig7
           ;;
		8) echo '状態(8)'
           fn_fig8
           ;;
	esac
}

function fn_hitAnyKey(){
	echo "> hit any key!"
	read keyin
}

function fn_menu() {
echo '===メニュー===================================='
PS3='番号を入力>'

menu_list='
ネットワークネームスペースを作成
ブリッジを作成
仮想ネットワークインタフェースを作成
仮想ネットワークインタフェースをネットワークネームスペースに配置
仮想ネットワークインタフェースをブリッジに配置
仮想ネットワークインタフェースにIPアドレスを設定
ネットワークネームスペースの仮想ネットワークインタフェースを有効化
ブリッジとブリッジの仮想ネットワークインタフェースを有効化
ネットワークネームスペースのループバックデバイスを有効化
ネットワークネームスペースを確認
ブリッジを確認
ネットワークネームスペースの仮想インタフェースを確認
ブリッジに接続された仮想インタフェースを確認
pingを実行
状態を表示
ネットワークネームスペースとブリッジをすべて削除
終了
課題提出用の出力'

select item in $menu_list
do
	echo ""
	echo "${REPLY}) ${item}します"
	case $REPLY in
	1) #ネットワークネームスペースを作成する
		echo sudo ip netns add ns1
		echo sudo ip netns add ns2
		echo sudo ip netns add ns3
        echo ''
		sudo ip netns add ns1
		sudo ip netns add ns2
		sudo ip netns add ns3
		stat=1
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp1
		;;
	2) #ブリッジを作成する
        echo sudo ip link add br1 type bridge
        echo ''
        sudo ip link add br1 type bridge
		stat=2
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp2
		;;
	3) #仮想ネットワークインタフェースを作成する
		echo sudo ip link add ns1-veth0 type veth peer name br1-veth0
		echo sudo ip link add ns2-veth0 type veth peer name br1-veth1
		echo sudo ip link add ns3-veth0 type veth peer name br1-veth2
        echo ''
		sudo ip link add ns1-veth0 type veth peer name br1-veth0
		sudo ip link add ns2-veth0 type veth peer name br1-veth1
		sudo ip link add ns3-veth0 type veth peer name br1-veth2
		stat=3
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp3
		;;
	4) #仮想ネットワークインタフェースをネットワークネームスペースに配置する
		echo sudo ip link set ns1-veth0 netns ns1
		echo sudo ip link set ns2-veth0 netns ns2
		echo sudo ip link set ns3-veth0 netns ns3
        echo ''
		sudo ip link set ns1-veth0 netns ns1
		sudo ip link set ns2-veth0 netns ns2
		sudo ip link set ns3-veth0 netns ns3
		stat=4
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp4
		;;
	5) #仮想ネットワークインタフェースをブリッジに配置する
		echo sudo ip link set dev br1-veth0 master br1
		echo sudo ip link set dev br1-veth1 master br1
		echo sudo ip link set dev br1-veth2 master br1
        echo ''
		sudo ip link set dev br1-veth0 master br1
		sudo ip link set dev br1-veth1 master br1
		sudo ip link set dev br1-veth2 master br1
		stat=5
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp5
		;;
	6) #仮想ネットワークインタフェースにIPアドレスを設定する
		echo sudo ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0 
		echo sudo ip netns exec ns2 ip address add 192.0.2.2/24 dev ns2-veth0 
		echo sudo ip netns exec ns3 ip address add 192.0.2.3/24 dev ns3-veth0 
        echo ''
		sudo ip netns exec ns1 ip address add 192.0.2.1/24 dev ns1-veth0 
		sudo ip netns exec ns2 ip address add 192.0.2.2/24 dev ns2-veth0 
		sudo ip netns exec ns3 ip address add 192.0.2.3/24 dev ns3-veth0 
		stat=6
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp6
		;;
	7) #ネットワークネームスペースの仮想ネットワークインタフェースを有効にする
		echo sudo ip netns exec ns1 ip link set ns1-veth0 up
		echo sudo ip netns exec ns2 ip link set ns2-veth0 up
		echo sudo ip netns exec ns3 ip link set ns3-veth0 up
        echo ''
		sudo ip netns exec ns1 ip link set ns1-veth0 up
		sudo ip netns exec ns2 ip link set ns2-veth0 up
		sudo ip netns exec ns3 ip link set ns3-veth0 up
		stat=7
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp7
		;;
	8) #ブリッジとブリッジのの仮想ネットワークインタフェースを有効にする
		echo sudo ip link set br1-veth0 up
		echo sudo ip link set br1-veth1 up
		echo sudo ip link set br1-veth2 up
		echo sudo ip link set br1 up
        echo ''
		sudo ip link set br1-veth0 up
		sudo ip link set br1-veth1 up
		sudo ip link set br1-veth2 up
		sudo ip link set br1 up
		stat=8
		echo $stat > ./.namespace_tmp
		fn_fig
        fn_exp8
		;;
	9) # 9:ネットワークネームスペースのループバックデバイスを有効にする
		echo sudo ip netns exec ns1 ip link set lo up
		echo sudo ip netns exec ns2 ip link set lo up
		echo sudo ip netns exec ns3 ip link set lo up
        echo ''
		sudo ip netns exec ns1 ip link set lo up
		sudo ip netns exec ns2 ip link set lo up
		sudo ip netns exec ns3 ip link set lo up
		;;
	10) #ネットワークネームスペースを確認する
		echo ip netns list
        echo ''
		ip netns list
		;;
	11) #ブリッジを確認する
        echo sudo ip link list br1
        echo ''
        sudo ip link list br1
		;;
	12) #仮想ネットワークインタフェースを確認する
		echo ''
        echo '----------------------------------------------------'
		echo sudo ip netns exec ns1 ip address list ns1-veth0
		echo ''
		sudo ip netns exec ns1 ip address list ns1-veth0
		echo ''
        echo '----------------------------------------------------'
		echo sudo ip netns exec ns2 ip address list ns2-veth0
		echo ''
		sudo ip netns exec ns2 ip address list ns2-veth0
        echo '----------------------------------------------------'
		echo sudo ip netns exec ns3 ip address list ns3-veth0
		echo ''
		sudo ip netns exec ns3 ip address list ns3-veth0
        echo '----------------------------------------------------'
		;;
	13) #ブリッジに接続された仮想ネットワークインタフェースを確認する
        echo sudo ip link list master br1
		echo ''
        sudo ip link list master br1
		;;
	14) #pingを実行(n1->n2)する
		echo "-----------------------------------------------------------"
		echo "pingコマンドでns1(192.0.2.1) から ns2(192.0.2.2)へ5パケット送信する"
		echo ''
		sudo ip netns exec ns1 ping -c 5 -I192.0.2.1 192.0.2.2 
		echo ''
		echo "-----------------------------------------------------------"
		echo "pingコマンドでns2(192.0.2.2) から ns3(192.0.2.3)へ5パケット送信する"
		echo ''
		sudo ip netns exec ns2 ping -c 5 -I192.0.2.2 192.0.2.3 
		echo ''
		echo "-----------------------------------------------------------"
		echo "pingコマンドでns3(192.0.2.3) から ns1(192.0.2.1)へ5パケット送信する"
		echo ''
		sudo ip netns exec ns3 ping -c 5 -I192.0.2.3 192.0.2.1 
		echo ''
		echo "-----------------------------------------------------------"
		;;
	15) #状態を表示する
		if [  -e ./.namespace_tmp ]
		then
			stat=$(cat ./.namespace_tmp)
        else
            stat=0
		fi
		fn_fig
		;;
	16) #ブリッジとネットワークネームスペースをすべて削除する
		echo sudo ip -all netns delete
	    echo sudo ip link del br1
        echo ''
		sudo ip -all netns delete
	    sudo ip link del br1
		stat=0
        if [ -e ./.namespace_tmp ]; then 
		    rm ./.namespace_tmp
        fi
		;;
	17) #終了する
		echo "bye bye!"
		exit
		;;
    18) #課題提出用の出力
        if [ $stat = 8 ]
        then
			echo ''
			echo '----ここから----'
			read -p '学生番号> ' unumber
			read -p '氏  名  > ' uname
			echo    'ID      >' $(echo $unumber | md5sum)
			echo ''
			date
			fn_fig        
			echo "-----------------------------------------------------------"
			echo "pingコマンドでns1(192.0.2.1) から ns2(192.0.2.2)へ5パケット送信する"
			sudo ip netns exec ns1 ping -c 5 -I192.0.2.1 192.0.2.2 
			echo ''
			echo "-----------------------------------------------------------"
			echo "pingコマンドでns2(192.0.2.2) から ns3(192.0.2.3)へ5パケット送信する"
			sudo ip netns exec ns2 ping -c 5 -I192.0.2.2 192.0.2.3 
			echo ''
			echo "-----------------------------------------------------------"
			echo "pingコマンドでns3(192.0.2.3) から ns1(192.0.2.1)へ5パケット送信する"
			sudo ip netns exec ns3 ping -c 5 -I192.0.2.3 192.0.2.1 
			echo '----ここまで----'
			echo ''
        else
			echo ''
			echo 'エラー：課題を出力できません。'
			echo ''
        fi
        ;;
	*)
		echo "番号を入力してください"
	esac

	echo ""
	echo "Enterキーを押してください。"
    read n

	#sleep 2
	fn_menu
done

}

#### START BASH SCRIPT #########################################################

echo '###'
echo '### Network Name Spaceを使った仮想ネットワークの作成'
echo '###'

echo ''
echo 'これから作成するネットワーク'
fn_fig8
sleep 3

echo ""
echo "Enterキーを押してください。"
read n

fn_menu
fn_hitAnyKey


# vim: number tabstop=4 softtabstop=4 shiftwidth=4 textwidth=0 filetype=text:
