# BlockAgric Smart Contract

## Overview

BlockAgric is a Clarity smart contract designed for tracking agricultural produce in a supply chain. It allows for the registration of products, updating their status and location, and retrieving product details and history.

## Features

- Register new agricultural products
- Update product status and location
- Retrieve product details
- Track product history
- Secure input validation

## Contract Details

- **File**: `blockagric.clar`
- **Language**: Clarity
- **Platform**: Stacks blockchain

## Functions

### Public Functions

1. `register-product`
   - **Purpose**: Register a new agricultural product
   - **Parameters**:
     - `name`: Product name (string-ascii, max 100 characters)
     - `description`: Product description (string-ascii, max 250 characters)
     - `location`: Initial product location (string-ascii, max 100 characters)
   - **Returns**: Product ID (uint) on success, or an error code

2. `update-product`
   - **Purpose**: Update an existing product's location and status
   - **Parameters**:
     - `product-id`: ID of the product to update (uint)
     - `location`: New product location (string-ascii, max 100 characters)
     - `status`: New product status (string-ascii, max 50 characters)
   - **Returns**: Boolean true on success, or an error code

3. `get-product-details`
   - **Purpose**: Retrieve details of a specific product
   - **Parameters**:
     - `product-id`: ID of the product to retrieve (uint)
   - **Returns**: Product details or an error code if not found

4. `get-product-history-entry`
   - **Purpose**: Retrieve a specific historical entry for a product
   - **Parameters**:
     - `product-id`: ID of the product (uint)
     - `history-id`: ID of the history entry (uint)
   - **Returns**: History entry details or an error code if not found

5. `get-product-history-count`
   - **Purpose**: Get the number of historical updates for a product
   - **Parameters**:
     - `product-id`: ID of the product (uint)
   - **Returns**: Number of updates or an error code if product not found

### Private Functions

1. `validate-string-length`
   - **Purpose**: Validate the length of input strings
   - Used internally to ensure input data meets length requirements

2. `is-valid-product-and-owner`
   - **Purpose**: Check if a product exists and if the caller is the owner
   - Used internally for authorization in update operations

## Error Codes

- `ERR-INVALID-STRING-LENGTH` (u1): Input string exceeds maximum length
- `ERR-PRODUCT-NOT-FOUND` (u2): Requested product does not exist
- `ERR-UNAUTHORIZED` (u3): Caller is not authorized to perform the operation
- `ERR-INVALID-INPUT` (u4): General invalid input error

## Usage

1. Deploy the contract to the Stacks blockchain.
2. Use the `register-product` function to add new products to the system.
3. Update product information using the `update-product` function.
4. Retrieve product details and history using the read-only functions.

## Security Considerations

- All input data is validated for length to prevent potential attacks.
- Only the original registrant of a product can update its information.
- The contract uses Clarity's built-in security features to prevent common vulnerabilities.

## Development and Testing

To work with this contract:

1. Set up a Clarity development environment.
2. Use the Clarinet console or write unit tests to interact with the contract.
3. Ensure all functions behave as expected, especially error handling and authorization checks.
