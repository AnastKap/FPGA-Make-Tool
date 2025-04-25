import subprocess
import json

INPUT_ORDER = ["frequency"]

METRIC_ORDER = ["slack", "min_cycles", "max_cycles", "bram_18k", "dsp", "ff", "lut", "urams"]
METRIC_PARETO_COMPARE_OPER = ["min", "min", "min", "min", "min", "min", "min", "min"]

OUTPUT_DATASET = "output_dataset.csv"
PARETO_DATASET = "pareto_dataset.csv"
RADAR_CHART_OUTPUT = "pareto_radar_chart"


def get_platforminfo():
    """Get platform information."""
    try:
        result = subprocess.run(
            ["platforminfo", "-p", "xilinx_u200_xdma_201830_2", "--json"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        platforminfo_file = result.stdout.strip()
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Error running platforminfo: {e.stderr.strip()}") from e

    # Parse the JSON output
    try:
        platforminfo_json = json.loads(platforminfo_file)
        temp = platforminfo_json.get("hardwarePlatform", {}).get("devices", [])[0].get("core", {}).get("availableResources", {})
        temp = temp.get("pBlocks", [])[0].get("resources", [])
        for i in temp:
            if i.get("name") == "BRAM_SLR0":
                BRAMs = int(i.get("value"))
            if i.get("name") == "DSPs_SLR0":
                DSPs = int(i.get("value"))
            if i.get("name") == "LUT_SLR0":
                LUTs = int(i.get("value"))
            if i.get("name") == "REG_SLR0":
                FFs = int(i.get("value"))
            if i.get("name") == "URAM_SLR0":
                URAMs = int(i.get("value"))
            if i.get("name") == "SLL_SLR0-SLR1":
                sll_0_1 = int(i.get("value"))
            if i.get("name") == "SLL_SLR1-SLR0":
                sll_1_0 = int(i.get("value"))
            if i.get("name") == "SLL_SLR1-SLR2":
                sll_1_2 = int(i.get("value"))
            if i.get("name") == "SLL_SLR2-SLR1":
                sll_2_1 = int(i.get("value"))
        print("Available pBlocks:", BRAMs)
        return BRAMs, DSPs, LUTs, FFs, URAMs, sll_0_1, sll_1_0, sll_1_2, sll_2_1
    except json.JSONDecodeError as e:
        raise RuntimeError(f"Error decoding JSON output: {e}") from e
    except KeyError as e:
        raise RuntimeError(f"Error accessing JSON data: {e}") from e


if __name__ == "__main__":
    # Get platform information
    try:
        b, d, l, f, u, sll_0_1, sll_1_0, sll_1_2, sll_2_1 = get_platforminfo()
        print("Platform information retrieved successfully.")
        print(f"BRAMs: {b}, DSPs: {d}, LUTs: {l}, FFs: {f}, URAMs: {u}")
        print(f"SLL SLR0-SLR1: {sll_0_1}, SLL SLR1-SLR0: {sll_1_0}, SLL SLR1-SLR2: {sll_1_2}, SLL SLR2-SLR1: {sll_2_1}")
    except Exception as e:
        print(f"Error retrieving platform information: {e}")