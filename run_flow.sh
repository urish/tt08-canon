PROJ_DIR=`pwd`
rm -rf runs/wokwi
mkdir -p runs/wokwi
pushd ~/tt/openlane2
nix-shell --run "cd $PROJ_DIR ; openlane --run-tag wokwi --force-run-dir runs/wokwi src/config_merged.json"
popd
cp runs/wokwi/final/pnl/* test/gate_level_netlist.v

