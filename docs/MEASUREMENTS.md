# Measurements

The first implementation favors reproducible geometry over unsupported anatomical claims.

## Current Experimental Outputs

- Mesh bounding width-to-height ratio in provider coordinate space.
- Mesh bounding width, height, and depth range in ARKit mesh coordinate space.
- Approximate left-right vertex balance around the mesh x-axis.
- Stable sample count and confidence derived from scan quality.

## Limitations

- ARKit mesh vertices are not treated as semantic anatomical landmarks.
- Millimeter-scale outputs are not claimed.
- Symmetry is descriptive geometry only and is not a diagnosis or universal beauty rule.
- Measurements are marked experimental until physically validated with known reference measurements.

## Future Requirements

Every future measurement must document:

- Name.
- Formula.
- Input points.
- Coordinate space.
- Normalization method.
- Unit.
- Confidence calculation.
- Known limitations.
- Algorithm version.
- Physical validation status.
