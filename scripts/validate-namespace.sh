#!/bin/bash

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CHART_PATH=$1
EXPECTED_NAMESPACE="istioinaction"

# Cluster-scoped resources that don't have namespace field
CLUSTER_SCOPED_RESOURCES=("Namespace" "ClusterRole" "ClusterRoleBinding" "CustomResourceDefinition" "PersistentVolume" "StorageClass")

if [ -z "$CHART_PATH" ]; then
    echo -e "${RED}Error: Chart path is required${NC}"
    echo "Usage: $0 <chart-path>"
    exit 1
fi

if [ ! -d "$CHART_PATH" ]; then
    echo -e "${RED}Error: Chart path '$CHART_PATH' does not exist${NC}"
    exit 1
fi

echo -e "${YELLOW}Validating namespace for chart: $CHART_PATH${NC}"
echo "Expected namespace: $EXPECTED_NAMESPACE"
echo ""

# Generate helm template output
TEMPLATE_OUTPUT=$(helm template "$CHART_PATH" "$CHART_PATH" 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to render helm template${NC}"
    echo "$TEMPLATE_OUTPUT"
    exit 1
fi

# Parse YAML and validate namespaces
validation_failed=false
resource_count=0
valid_count=0
error_messages=()

# Process the template output line by line
current_kind=""
current_name=""
current_namespace=""
in_metadata=false

while IFS= read -r line; do
    # Detect document separator (new resource)
    if [[ "$line" =~ ^---$ ]] || [[ "$line" =~ ^# ]]; then
        # Validate previous resource if we have one
        if [ -n "$current_kind" ]; then
            resource_count=$((resource_count + 1))
            
            # Check if it's a cluster-scoped resource
            is_cluster_scoped=false
            for cluster_resource in "${CLUSTER_SCOPED_RESOURCES[@]}"; do
                if [ "$current_kind" == "$cluster_resource" ]; then
                    is_cluster_scoped=true
                    break
                fi
            done
            
            if [ "$is_cluster_scoped" = true ]; then
                # Skip validation for cluster-scoped resources
                valid_count=$((valid_count + 1))
            else
                # Validate namespace
                if [ -z "$current_namespace" ]; then
                    validation_failed=true
                    error_messages+=("❌ ${current_kind}/${current_name}: missing namespace field")
                elif [ "$current_namespace" != "$EXPECTED_NAMESPACE" ]; then
                    validation_failed=true
                    error_messages+=("❌ ${current_kind}/${current_name}: has namespace '$current_namespace' instead of '$EXPECTED_NAMESPACE'")
                else
                    valid_count=$((valid_count + 1))
                fi
            fi
        fi
        
        # Reset for next resource
        current_kind=""
        current_name=""
        current_namespace=""
        in_metadata=false
        continue
    fi
    
    # Skip comment lines and empty lines
    if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
        continue
    fi
    
    # Extract kind
    if [[ "$line" =~ ^kind:[[:space:]]*(.+)$ ]]; then
        current_kind="${BASH_REMATCH[1]}"
    fi
    
    # Detect metadata section
    if [[ "$line" =~ ^metadata: ]]; then
        in_metadata=true
    elif [[ "$line" =~ ^[a-zA-Z] ]] && [ "$in_metadata" = true ]; then
        in_metadata=false
    fi
    
    # Extract name from metadata
    if [ "$in_metadata" = true ] && [[ "$line" =~ ^[[:space:]]+name:[[:space:]]*(.+)$ ]]; then
        current_name="${BASH_REMATCH[1]}"
    fi
    
    # Extract namespace from metadata
    if [ "$in_metadata" = true ] && [[ "$line" =~ ^[[:space:]]+namespace:[[:space:]]*(.+)$ ]]; then
        current_namespace="${BASH_REMATCH[1]}"
    fi
done <<< "$TEMPLATE_OUTPUT"

# Validate last resource
if [ -n "$current_kind" ]; then
    resource_count=$((resource_count + 1))
    
    # Check if it's a cluster-scoped resource
    is_cluster_scoped=false
    for cluster_resource in "${CLUSTER_SCOPED_RESOURCES[@]}"; do
        if [ "$current_kind" == "$cluster_resource" ]; then
            is_cluster_scoped=true
            break
        fi
    done
    
    if [ "$is_cluster_scoped" = true ]; then
        valid_count=$((valid_count + 1))
    else
        if [ -z "$current_namespace" ]; then
            validation_failed=true
            error_messages+=("❌ ${current_kind}/${current_name}: missing namespace field")
        elif [ "$current_namespace" != "$EXPECTED_NAMESPACE" ]; then
            validation_failed=true
            error_messages+=("❌ ${current_kind}/${current_name}: has namespace '$current_namespace' instead of '$EXPECTED_NAMESPACE'")
        else
            valid_count=$((valid_count + 1))
        fi
    fi
fi

# Print results
echo -e "${YELLOW}Validation Results:${NC}"
echo "Total resources: $resource_count"
echo "Valid resources: $valid_count"
echo ""

if [ "$validation_failed" = true ]; then
    echo -e "${RED}Validation FAILED!${NC}"
    echo ""
    echo "Resources with namespace issues:"
    for error_msg in "${error_messages[@]}"; do
        echo -e "$error_msg"
    done
    exit 1
else
    echo -e "${GREEN}✓ All resources have correct namespace: $EXPECTED_NAMESPACE${NC}"
    exit 0
fi
