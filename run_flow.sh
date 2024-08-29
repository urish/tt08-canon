PROJ_DIR=`pwd`
rm -rf runs/wokwi
mkdir -p runs/wokwi
pushd ~/tt/openlane2
nix-shell --run "cd $PROJ_DIR ; openlane --run-tag wokwi --force-run-dir runs/wokwi src/config_merged.json"
popd
cp runs/wokwi/final/pnl/* test/gate_level_netlist.v

rm -rf tt_submission
mkdir -p tt_submission/stats

TOP_MODULE=$(./tt/tt_tool.py --print-top-module --openlane2)
cp runs/wokwi/final/{gds,lef,spef/*}/${TOP_MODULE}.* tt_submission/
cp runs/wokwi/final/pnl/${TOP_MODULE}.pnl.v tt_submission/${TOP_MODULE}.v
cp runs/wokwi/resolved.json tt_submission/
cp runs/wokwi/final/metrics.csv tt_submission/stats/metrics.csv
cp runs/wokwi/*-yosys-synthesis/reports/stat.log tt_submission/stats/synthesis-stats.txt