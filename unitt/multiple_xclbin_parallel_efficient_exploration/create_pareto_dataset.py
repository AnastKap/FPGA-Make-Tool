import numpy as np
import pandas as pd
import common as common
import matplotlib.pyplot as plt

def load_dataset(file_path):
    """Load the dataset from the given file path."""
    return pd.read_csv(file_path)

def is_pareto_efficient(costs):
    """Find the Pareto-efficient points."""
    is_efficient = np.ones(costs.shape[0], dtype=bool)
    for i, c in enumerate(costs):
        if is_efficient[i]:
            is_efficient[is_efficient] = np.any(costs[is_efficient] < c, axis=1)  # Keep any point with a lower cost
            is_efficient[i] = True  # And keep self
    return is_efficient

def find_pareto_front(dataset, input_order, compare_oper):
    """Find the Pareto front from the dataset."""
    inputs = dataset.iloc[:, :len(input_order)].values
    outputs = dataset.iloc[:, len(input_order):].values
    for i, oper in enumerate(compare_oper):
        if oper == "min":
            continue
        elif oper == "max":
            outputs[:, i] = -outputs[:, i]
        else:
            raise ValueError(f"Invalid operation '{oper}' in compare_oper. Expected 'min' or 'max'.")
    pareto_mask = is_pareto_efficient(outputs)
    pareto_front = dataset[pareto_mask]
    pareto_front = pareto_front.abs()
    return pareto_front


class RADAR_CHART_TYPES:
    """Class to define radar chart types."""
    PERCENTAGES_DEFAULT = "percentages_default"
    PERCENTAGES_NORMALIZED = "percentages_normalized"
    ABSOLUTE_VALS_NORMALIZED = "absolute_normalized"


def radar_chart_preprocess(data, type):
    if type == RADAR_CHART_TYPES.ABSOLUTE_VALS_NORMALIZED:
        # Normalize per variable the data for radar chart (no normalization per a global min/max)
        normalized_data = data
        # Normalize data for each axis independently
        for i in range(normalized_data.shape[1]):
            col_max = normalized_data[:, i].max()
            normalized_data[:, i] = normalized_data[:, i] / col_max
        ret_data = normalized_data
    elif "percentages" in type:
        total_brams, total_dsps, total_luts, total_ffs, total_u, _, _, _, _ = common.get_platforminfo()
        #if type == RADAR_CHART_TYPES.PERCENTAGES_DEFAULT

    
    return ret_data


# Plot a radar chart for the Pareto optimal points
def plot_radar_chart(pareto_front, metric_order, output_path, type):
    """Plot a radar chart for the Pareto optimal points."""
    #if len(input_order) != len(metric_order):
    #    raise ValueError("The number of regions must be equal to the number of elements in 'metric_names'.")

    categories = metric_order
    num_vars = len(categories)

    # Compute angle for each axis
    angles = np.linspace(0, 2 * np.pi, num_vars, endpoint=False).tolist()
    angles += angles[:1]  # Complete the loop

    data = radar_chart_preprocess(pareto_front[metric_order].values, type)

    # Plot each Pareto optimal point
    _, ax = plt.subplots(figsize=(6, 6), subplot_kw=dict(polar=True))
    for row in data:
        values = row.tolist()
        values += values[:1]  # Complete the loop
        ax.plot(angles, values, linewidth=2, linestyle='solid')
        #ax.fill(angles, values, alpha=0.25)

    # Add labels
    ax.set_yticks([])
    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(metric_order)

    plt.title("Radar Chart of Pareto Optimal Points")
    plt.savefig(output_path + ".png", format='png', dpi=300)
    plt.close()




if __name__ == "__main__":
    # Path to the dataset
    dataset_path = common.OUTPUT_DATASET  # Replace with the actual path to your dataset

    # Define the input order (list of input column names)
    input_order = common.INPUT_ORDER
    metric_order = common.METRIC_ORDER
    compare_oper = common.METRIC_PARETO_COMPARE_OPER
    assert len(compare_oper) == len(metric_order), "compare_oper and metric_order must have the same length"

    # Load the dataset
    dataset = load_dataset(dataset_path)

    # Find the Pareto front
    pareto_front = find_pareto_front(dataset, input_order, compare_oper)

    pareto_out = common.PARETO_DATASET
    # Save the Pareto front to a new file
    pareto_front.to_csv(pareto_out, index=False)
    print(f"Pareto front saved to {pareto_out}")

    # Plot the radar chart
    plot_radar_chart(pareto_front, metric_order, common.RADAR_CHART_OUTPUT + "_abs_norm", RADAR_CHART_TYPES.ABSOLUTE_VALS_NORMALIZED)
    #plot_radar_chart(pareto_front, metric_order, common.RADAR_CHART_OUTPUT + "_abs_norm", RADAR_CHART_TYPES.PERCENTAGES_DEFAULT)