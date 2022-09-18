hybridswapfiles=`ls -l /sys/block/zram0/hybridswap_* | grep ^'\-rw\-' | awk '{print $NF}'`

chmod o+w $hybridswapfiles
echo "		`cat /dev/memcg/memory.swapd_memcgs_param`"
echo "		`cat /dev/memcg/memory.app_score`"
echo "		`cat /dev/memcg/apps/memory.app_score`"
echo "		`cat /dev/memcg/memory.name`"
echo "		`cat /dev/memcg/apps/memory.name`"

echo "		`cat /dev/memcg/memory.avail_buffers`"
echo "		`cat /dev/memcg/memory.zram_critical_threshold`"
echo "		`cat /dev/memcg/memory.swapd_max_reclaim_size`"
echo "		`cat /dev/memcg/memory.swapd_shrink_parameter`"
echo "		`cat /dev/memcg/memory.max_skip_interval`"
echo "		`cat /dev/memcg/memory.reclaim_exceed_sleep_ms`"
echo "		`cat /dev/memcg/memory.cpuload_threshold`"
echo "		`cat /dev/memcg/memory.max_reclaimin_size_mb`"
echo "		`cat /dev/memcg/memory.zram_wm_ratio`"
echo "		`cat /dev/memcg/memory.empty_round_skip_interval`"
echo "		`cat /dev/memcg/memory.empty_round_check_threshold`"
echo "		`cat /sys/block/zram0/hybridswap_loglevel`"
echo "		`cat /sys/block/zram0/hybridswap_loop_device`"
echo "		`cat /sys/block/zram0/hybridswap_enable`"
echo "		`cat /dev/memcg/memory.swapd_bind`"
echo "		`cat /sys/block/zram0/hybridswap_zram_increase`"

loop_device_num=`echo $loop_device |awk -F/ '{print $4}'`
echo "		`cat /sys/block/$loop_device_num/queue/scheduler`"