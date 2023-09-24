#!/bin/bash

# DIR_WORKSPACE         - working directory
# DIR_ACTIONS           - actions directory
# DIR_FORMER_FILES      - former files directory from last commit
# DIR_FORMER_PACKAGES   - former packages directory from last commit
# TARGET                - workflow target
# MERGE_FORMER_PACKAGES - whether to merge packages from last commit

cd "$DIR_WORKSPACE"

function svn_export() {
    echo "SVN exporting $1 ..."
    svn export -q "$1" "${@:2}"
}
source "$DIR_ACTIONS/tools/clone-tools"
source "$DIR_ACTIONS/tools/hash"
source "$DIR_ACTIONS/tools/random"
source "$DIR_ACTIONS/tools/merge"
source "$DIR_ACTIONS/tools/fix"
export GITHUB_HOST="https://github.com"
export FETCH_PKG_BASE="https://github.com/"
export SVN_EXPORT_BASE="https://github.com/"


# ===> Fetch
echo ::group::"Fetching..."

fetch_pkg kenzo78/my-packages %$(rnd)% | extract -n -r
fetch_pkg kiddin9/luci-app-dnsfilter
fetch_pkg kiddin9/aria2
fetch_pkg kiddin9/luci-app-baidupcs-web
fetch_pkg kiddin9/qBittorrent-Enhanced-Edition
fetch_pkg kiddin9/autoshare %$(rnd)% | extract -n -r
fetch_pkg kiddin9/openwrt-openvpn %$(rnd)% | extract -n -r
fetch_pkg kiddin9/luci-app-xlnetacc
fetch_pkg kiddin9/luci-app-wizard
fetch_pkg kiddin9/luci-theme-edge -b 18.06
fetch_pkg yichya/luci-app-xray
fetch_pkg Lienol/openwrt-package
fetch_pkg ysc3839/openwrt-minieap
fetch_pkg ysc3839/luci-proto-minieap
fetch_pkg BoringCat/luci-app-mentohust
fetch_pkg BoringCat/luci-app-minieap
fetch_pkg peter-tank/luci-app-dnscrypt-proxy2
fetch_pkg peter-tank/luci-app-autorepeater
fetch_pkg rufengsuixing/luci-app-autoipsetadder
fetch_pkg ElvenP/luci-app-onliner
fetch_pkg rufengsuixing/luci-app-usb3disable
fetch_pkg riverscn/openwrt-iptvhelper %$(rnd)% | extract -n -r
fetch_pkg KyleRicardo/MentoHUST-OpenWrt-ipk
fetch_pkg NateLol/luci-app-beardropper
fetch_pkg yaof2/luci-app-ikoolproxy
fetch_pkg project-lede/luci-app-godproxy
fetch_pkg tty228/luci-app-wechatpush
fetch_pkg 4IceG/luci-app-sms-tool %$(rnd)% | extract -n -r
fetch_pkg silime/luci-app-xunlei
fetch_pkg BCYDTZ/luci-app-UUGameAcc
fetch_pkg ntlf9t/luci-app-easymesh
fetch_pkg zzsj0928/luci-app-pushbot
fetch_pkg shanglanxin/luci-app-homebridge
fetch_pkg esirplayground/luci-app-poweroff
fetch_pkg esirplayground/LingTiGameAcc
fetch_pkg esirplayground/luci-app-LingTiGameAcc
fetch_pkg brvphoenix/luci-app-wrtbwmon %$(rnd)% | extract -n -r
fetch_pkg brvphoenix/wrtbwmon %$(rnd)% | extract -n -r
fetch_pkg jerrykuku/luci-theme-argon
fetch_pkg jerrykuku/luci-app-argon-config
fetch_pkg jerrykuku/luci-app-vssr
fetch_pkg jerrykuku/luci-app-ttnode
fetch_pkg jerrykuku/luci-app-jd-dailybonus
fetch_pkg jerrykuku/luci-app-go-aliyundrive-webdav
fetch_pkg jerrykuku/lua-maxminddb
fetch_pkg sirpdboy/luci-app-advanced
fetch_pkg sirpdboy/luci-theme-opentopd
fetch_pkg sirpdboy/luci-app-poweroffdevice
fetch_pkg sirpdboy/luci-app-autotimeset
fetch_pkg sirpdboy/luci-app-lucky %$(rnd)% | extract -n -r -s luci-app-lucky
fetch_pkg sirpdboy/luci-app-partexp
fetch_pkg sirpdboy/chatgpt-web
fetch_pkg sirpdboy/luci-app-ddns-go %$(rnd)% | extract -n -r
fetch_pkg sirpdboy/netspeedtest %$(rnd)% | extract -r
fetch_pkg Jason6111/luci-app-netdata
fetch_pkg KFERMercer/luci-app-tcpdump
fetch_pkg jefferymvp/luci-app-koolproxyR
fetch_pkg wolandmaster/luci-app-rtorrent
fetch_pkg NateLol/luci-app-oled
fetch_pkg hubbylei/luci-app-clash
fetch_pkg destan19/OpenAppFilter %$(rnd)% | extract -n -r
fetch_pkg lvqier/luci-app-dnsmasq-ipset
fetch_pkg walkingsky/luci-wifidog luci-app-wifidog
fetch_pkg CCnut/feed-netkeeper %$(rnd)% | extract -n -r
fetch_pkg sensec/luci-app-udp2raw
fetch_pkg LGA1150/openwrt-sysuh3c %$(rnd)% | extract -n -r
fetch_pkg Hyy2001X/AutoBuild-Packages %$(rnd)% | extract -n -r -s ~luci-app-adguardhome
fetch_pkg gdck/luci-app-cupsd %$(rnd)% | extract -n -r -s luci-app-cupsd cups/cups
fetch_pkg kenzok8/wall %$(rnd)% | extract -n -r -s ~alist ~mosdns
fetch_pkg peter-tank/luci-app-fullconenat
fetch_pkg sirpdboy/sirpdboy-package %$(rnd)% | extract -n -r -s luci-app-dockerman
fetch_pkg sundaqiang/openwrt-packages %$(rnd)% | extract -n -r -s 'luci-*'
fetch_pkg zxlhhyccc/luci-app-v2raya
fetch_pkg kenzok8/luci-theme-ifit %$(rnd)% | extract -n -r -s luci-theme-ifit
fetch_pkg kenzok78/openwrt-minisign
fetch_pkg kenzok78/luci-theme-argone
fetch_pkg kenzok78/luci-app-argone-config
fetch_pkg kenzok78/luci-app-adguardhome
fetch_pkg gngpp/luci-theme-design
fetch_pkg gngpp/luci-app-design-config
fetch_pkg pymumu/luci-app-smartdns -b lede
fetch_pkg ophub/luci-app-amlogic %$(rnd)% | extract -n -r -s luci-app-amlogic
fetch_pkg linkease/nas-packages %$(rnd)% | extract -n -r -s 'network/services/*' 'multimedia/*'
fetch_pkg linkease/nas-packages-luci %$(rnd)% | extract -n -r -s 'luci/*'
fetch_pkg linkease/istore %$(rnd)% | extract -n -r -s 'luci/*'
fetch_pkg AlexZhuo/luci-app-bandwidthd
fetch_pkg linkease/openwrt-app-actions
fetch_pkg ZeaKyX/luci-app-speedtest-web
fetch_pkg ZeaKyX/speedtest-web
fetch_pkg Huangjoe123/luci-app-eqos
fetch_pkg honwen/luci-app-aliddns
fetch_pkg immortalwrt/homeproxy
fetch_pkg ximiTech/luci-app-msd_lite
fetch_pkg UnblockNeteaseMusic/luci-app-unblockneteasemusic -b master
fetch_pkg sbwml/luci-app-alist %$(rnd)% | extract -n -r -s '*alist'
fetch_pkg vernesong/OpenClash %$(rnd)% | extract -n -r -s luci-app-openclash
fetch_pkg messense/aliyundrive-webdav %$(rnd)% | extract -n -r -s 'openwrt/*'
fetch_pkg messense/aliyundrive-fuse %$(rnd)% | extract -n -r -s 'openwrt/*'
fetch_pkg kenzok8/litte %$(rnd)% | extract -n -r -s luci-theme-atmaterial_new luci-theme-mcat luci-theme-tomato
fetch_pkg fw876/helloworld %$(rnd)% | extract -n -r -s luci-app-ssr-plus tuic-client
# fetch_pkg QiuSimons/openwrt-mos %$(rnd)% | extract -n -r -s luci-app-mosdns
fetch_pkg sbwml/luci-app-mosdns %$(rnd)% | extract -n -r -s '*mosdns' v2dat
fetch_pkg xiaorouji/openwrt-passwall2 %$(rnd)% | extract -n -r -s luci-app-passwall2
fetch_pkg xiaorouji/openwrt-passwall -b luci %$(rnd)% | extract -n -r -s luci-app-passwall
fetch_pkg SSSSSimon/tencentcloud-openwrt-plugin-ddns %$(rnd)% | extract -n -r -s tencentcloud_ddns && \
    mv -n tencentcloud_ddns luci-app-tencentddns
fetch_pkg Tencent-Cloud-Plugins/tencentcloud-openwrt-plugin-cos %$(rnd)% | extract -n -r -s tencentcloud_cos && \
    mv -n tencentcloud_cos luci-app-tencentcloud-cos
fetch_pkg kiddin9/openwrt-packages %$(rnd)% | extract -n -r -s luci-app-bypass luci-app-fileassistant
fetch_pkg immortalwrt/packages %$(rnd)% | extract -n -r -s net/cdnspeedtest
fetch_pkg immortalwrt/luci %$(rnd)% | extract -n -r -s applications/luci-app-gost applications/luci-app-filebrowser
fetch_pkg mingxiaoyu/luci-app-cloudflarespeedtest %$(rnd)% | extract -n -r -s 'applications/*'
fetch_pkg doushang/luci-app-shortcutmenu %$(rnd)% | extract -n -r -s luci-app-shortcutmenu
fetch_pkg sbilly/netmaker-openwrt %$(rnd)% | extract -n -r -s netmaker
fetch_pkg coolsnowwolf/packages %$(rnd)% | extract -n -r -s multimedia/UnblockNeteaseMusic-Go net/msd_lite

svn_export $GITHUB_HOST/coolsnowwolf/luci/trunk/libs/luci-lib-ipkg
svn_export $GITHUB_HOST/x-wrt/packages/trunk/net/nft-qos
svn_export $GITHUB_HOST/x-wrt/luci/trunk/applications/luci-app-nft-qos
svn_export $GITHUB_HOST/Lienol/openwrt-package/branches/other/lean/luci-app-autoreboot
svn_export $GITHUB_HOST/Ysurac/openmptcprouter-feeds/trunk/luci-app-iperf
svn_export $GITHUB_HOST/openwrt/packages/trunk/net/shadowsocks-libev
svn_export $GITHUB_HOST/kenzok8/wall/trunk/gn
svn_export $GITHUB_HOST/kenzok8/jell/trunk/vsftpd-alt
svn_export $GITHUB_HOST/kenzok8/jell/trunk/luci-app-bridge
svn_export $GITHUB_HOST/coolsnowwolf/lede/trunk/package/lean/ucl --force

fetch_pkg coolsnowwolf/packages --sparse \
    net/miniupnpd net/mwan3 net/amule net/baidupcs-web multimedia/gmediarender \
    net/go-aliyundrive-webdav net/qBittorrent-static net/qBittorrent libs/qtbase \
    libs/qttools libs/rblibtorrent net/uugamebooster net/verysync \
    net/dnsforwarder net/nps net/tcpping
mv -f miniupnpd miniupnpd-iptables

fetch_pkg openwrt/packages -b openwrt-23.05 --sparse \
    utils/cgroupfs-mount utils/coremark utils/watchcat utils/dockerd \
    net/nginx net/uwsgi net/ddns-scripts net/ariang \
    admin/netdata net/transmission-web-control net/rp-pppoe net/tailscale

fetch_pkg openwrt/openwrt -b openwrt-23.05 --sparse \
    package/base-files package/network/config/firewall4 \
    package/network/config/firewall \
    package/system/opkg \
    package/network/services/ppp \
    package/network/services/dnsmasq package/libs/

fetch_pkg immortalwrt/packages --sparse \
    net/sub-web net/dnsproxy net/haproxy net/cdnspeedtest net/subconverter net/ngrokc \
    net/oscam net/njitclient net/scutclient net/gowebdav admin/btop \
    libs/wxbase libs/rapidjson libs/libcron libs/quickjspp libs/toml11 libs/libtorrent-rasterbar \
    libs/libdouble-conversion libs/qt6base libs/cxxopts libs/jpcre2 libs/alac utils/cpulimit

fetch_pkg Ysurac/openmptcprouter-feeds -b develop --sparse \
    luci-app-snmpd luci-app-packet-capture luci-app-mail msmtp

fetch_pkg xiaoqingfengATGH/feeds-xiaoqingfeng --sparse \
    homeredirect luci-app-homeredirect

fetch_pkg x-wrt/com.x-wrt --sparse \
    natflow lua-ipops luci-app-macvlan

fetch_pkg immortalwrt/immortalwrt --sparse \
    package/network/utils/nftables package/network/utils/fullconenat package/network/utils/fullconenat-nft \
    package/utils/mhz package/libs/libnftnl package/firmware/wireless-regdb

fetch_pkg -b openwrt-23.05 openwrt/luci --sparse \
    applications/luci-app-watchcat


# mv -n openwrt-passwall/* ./ ; rm -rf openwrt-passwall
mv -n openwrt-package/* ./ ; rm -rf openwrt-package
mv -n openwrt-app-actions/applications/* ./;rm -rf openwrt-app-actions

echo ::endgroup::


# ===> Fix
echo ::group::"Fixing..."

fix_upx speedtest-web

sed -i \
-e 's?include \.\./\.\./\(lang\|devel\)?include $(TOPDIR)/feeds/packages/\1?' \
-e 's?2. Clash For OpenWRT?3. Applications?' \
-e 's?\.\./\.\./luci.mk?$(TOPDIR)/feeds/luci/luci.mk?' \
-e 's/ca-certificates/ca-bundle/' \
-e 's/php7/php8/g' \
-e 's/+docker /+docker +dockerd /g' \
*/Makefile

sed -i 's/download\/v$(PKG_VERSION)\/$(PKG_SOURCE)/download\/v$(PKG_VERSION)/' upx/Makefile
sed -i 's/977857ff7602f701ec6310c984a747308ed7f34bef6e963fcb41bd7fa5c51d22/0582f78b517ea87ba1caa6e8c111474f58edd167e5f01f074d7d9ca2f81d47d0/' upx/Makefile
sed -i 's/luci-lib-ipkg/luci-base/g' luci-app-store/Makefile
sed -i "/minisign:minisign/d" luci-app-dnscrypt-proxy2/Makefile
sed -i 's/+dockerd/+dockerd +cgroupfs-mount/' luci-app-docker*/Makefile
sed -i '$i /etc/init.d/dockerd restart &' luci-app-docker*/root/etc/uci-defaults/*
sed -i 's/+libcap /+libcap +libcap-bin /' luci-app-openclash/Makefile
sed -i 's/\(+luci-compat\)/\1 +luci-theme-argon/' luci-app-argon-config/Makefile
sed -i 's/\(+luci-compat\)/\1 +luci-theme-design/' luci-app-design-config/Makefile
sed -i 's/\(+luci-compat\)/\1 +luci-theme-argone/' luci-app-argone-config/Makefile
sed -i 's/ +uhttpd-mod-ubus//' luci-app-packet-capture/Makefile
sed -i 's/	ip.neighbors/	luci.ip.neighbors/' luci-app-wifidog/luasrc/model/cbi/wifidog/wifidog_cfg.lua
# sed -i -e 's/nas/services/g' -e 's/NAS/Services/g' $(grep -rl 'nas\|NAS' luci-app-fileassistant)
# sed -i -e 's/nas/services/g' -e 's/NAS/Services/g' $(grep -rl 'nas\|NAS' luci-app-alist)
# find . -type f -name Makefile -exec sed -i 's/PKG_BUILD_FLAGS:=no-mips16/PKG_USE_MIPS16:=0/g' {} +
sed -i '65,73d' adguardhome/Makefile
sed -i 's/PKG_SOURCE_DATE:=2/PKG_SOURCE_DATE:=3/' transmission-web-control/Makefile
# find . -type f -name Makefile -exec sed -i 's/PKG_BUILD_FLAGS:=no-mips16/PKG_USE_MIPS16:=0/g' {} +

echo ::endgroup::


# ==> Translate
echo ::group::"Translating"

for e in $(ls -d luci-*/po); do
	if [[ -d $e/zh-cn && ! -d $e/zh_Hans ]]; then
		ln -s zh-cn $e/zh_Hans 2>/dev/null
	elif [[ -d $e/zh_Hans && ! -d $e/zh-cn ]]; then
		ln -s zh_Hans $e/zh-cn 2>/dev/null
	fi
done

echo ::endgroup::


# ==> Create ACL file for LuCI
echo ::group::"Create ACL file for LuCI"

eval "$DIR_ACTIONS/src/create_acl_for_luci.sh -a"

echo ::endgroup::


# ===> Clean
echo ::group::"Cleaning..."

rm -rf create_acl_for_luci.err create_acl_for_luci.ok create_acl_for_luci.warn \
    ./*/.git ./*/.gitattributes ./*/.svn ./*/.github ./*/.gitignore ./*/.gitmodules

echo ::endgroup::