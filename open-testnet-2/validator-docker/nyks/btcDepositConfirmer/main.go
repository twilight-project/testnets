package main

import (
        "crypto/rand"
        "database/sql"
        "encoding/hex"
        "encoding/json"
        "fmt"
        "net/http"
        "os/exec"
        "strings"

        "github.com/rs/cors"
        _ "github.com/jackc/pgx/v5/stdlib" // postgres driver
)

const (
        dbHost     = "zkpass_database" // Docker service name
        dbPort     = 5432              // Internal port
        dbUser     = "zkpass"
        dbPassword = "zkpass"
        dbName     = "zkpass"
)

type RequestPayload struct {
        RecipientAddress string `json:"recipientAddress"`
}
type APIError struct {
        Code    string `json:"code"`
        Details string `json:"details,omitempty"`
}

type APIResponse struct {
        Status  string      `json:"status"`            // "success" | "error"
        Data    interface{} `json:"data,omitempty"`    // present on success
        Error   *APIError   `json:"error,omitempty"`   // present on error
        Message string      `json:"message,omitempty"` // optional human message
}


func generateRandomHash() (string, error) {
	// Create a 32-byte array
	randomBytes := make([]byte, 32)

	// Fill the array with random bytes
	_, err := rand.Read(randomBytes)
	if err != nil {
		return "", fmt.Errorf("failed to generate random bytes: %w", err)
	}

	// Encode the bytes into a hexadecimal string
	hash := hex.EncodeToString(randomBytes)
	return hash, nil
}

// runBTCDepositConfirmation runs the specified command with the provided parameters.
func runBTCDepositConfirmation(recipientAddress string) error {
	addrBytes, err := exec.Command(
		"nyksd", "keys", "show", "validator-self",
		"-a", "--keyring-backend", "test",
	).Output()
	if err != nil {
		return fmt.Errorf("failed to get validator address: %w", err)
	}
	validatorAddr := strings.TrimSpace(string(addrBytes)) // remove trailing newline

	tx_id, err := generateRandomHash()
	if err != nil {
		return fmt.Errorf("failed to generate random hash: %w", err)
	}
	cmd := exec.Command(
		"nyksd", "tx", "bridge", "msg-confirm-btc-deposit", "14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM", "50000", "50000",
		tx_id,
		recipientAddress,
		validatorAddr,
		"--from", "validator-self",
		"--chain-id", "nyks",
		"--keyring-backend", "test",
		"--yes",
	)
	// 2. Force the right HOME so nyksd sees your test keyring
	// cmd.Env = append(os.Environ(),"HOME=${HOME}",)

	// Run the command and capture output
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to execute command: %w\nOutput: %s", err, string(output))
	}

	fmt.Printf("Command executed successfully:\n%s\n", string(output))
	return nil
}

// runBTCDepositConfirmation runs the specified command with the provided parameters.
func runBTCDepositConfirmationRelayerWallet(recipientAddress string) error {
	addrBytes, err := exec.Command(
		"nyksd", "keys", "show", "validator-self",
		"-a", "--keyring-backend", "test",
	).Output()
	if err != nil {
		return fmt.Errorf("failed to get validator address: %w", err)
	}
	validatorAddr := strings.TrimSpace(string(addrBytes)) // remove trailing newline

	tx_id, err := generateRandomHash()
	if err != nil {
		return fmt.Errorf("failed to generate random hash: %w", err)
	}
	cmd := exec.Command(
		"nyksd", "tx", "bridge", "msg-confirm-btc-deposit", "14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM", "500000000", "50000",
		tx_id,
		recipientAddress,
		validatorAddr,
		"--from", "validator-self",
		"--chain-id", "nyks",
		"--keyring-backend", "test",
		"--yes",
	)
	// 2. Force the right HOME so nyksd sees your test keyring
	// cmd.Env = append(os.Environ(),"HOME=${HOME}",)

	// Run the command and capture output
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to execute command: %w\nOutput: %s", err, string(output))
	}

	fmt.Printf("Command executed successfully:\n%s\n", string(output))
	return nil
}

func runBankSendCommand(toAddress string) error {
	// Construct the command
	cmd := exec.Command(
		"nyksd", "tx", "bank", "send",
		"faucet",
		toAddress,
		"100000nyks",
		"--keyring-backend", "test",
		"--chain-id", "nyks",
		"--yes",
	)
	// 2. Force the right HOME so nyksd sees your test keyring
	// cmd.Env = append(os.Environ(),"HOME=${HOME}",)
	// Run the command and capture output
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to execute command: %w\nOutput: %s", err, string(output))
	}

	fmt.Printf("Command executed successfully:\n%s\n", string(output))
	return nil
}

func handlemint(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var payload RequestPayload
	err := json.NewDecoder(r.Body).Decode(&payload)
	if err != nil {
		http.Error(w, "Invalid JSON payload", http.StatusBadRequest)
		return
	}

	if payload.RecipientAddress == "" {
		http.Error(w, "recipientAddress is required", http.StatusBadRequest)
		return
	}

	err = runBTCDepositConfirmation(payload.RecipientAddress)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to run command: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Command executed successfully"))
}
func handlemintRelayerWallet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var payload RequestPayload
	err := json.NewDecoder(r.Body).Decode(&payload)
	if err != nil {
		http.Error(w, "Invalid JSON payload", http.StatusBadRequest)
		return
	}

	if payload.RecipientAddress == "" {
		http.Error(w, "recipientAddress is required", http.StatusBadRequest)
		return
	}

	err = runBTCDepositConfirmationRelayerWallet(payload.RecipientAddress)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to run command: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Command executed successfully"))
}

func handlefaucet(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var payload RequestPayload
	err := json.NewDecoder(r.Body).Decode(&payload)
	if err != nil {
		http.Error(w, "Invalid JSON payload", http.StatusBadRequest)
		return
	}

	if payload.RecipientAddress == "" {
		http.Error(w, "recipientAddress is required", http.StatusBadRequest)
		return
	}

	err = runBankSendCommand(payload.RecipientAddress)
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to run command: %v", err), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Command executed successfully"))
}

func connectToDatabase() (*sql.DB, error) {
	connectionString := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName)

	db, err := sql.Open("pgx", connectionString)
	if err != nil {
		return nil, fmt.Errorf("failed to open database connection: %w", err)
	}

	// Test the connection
	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return db, nil
}

func checkAddressExists(address string) (bool, error) {
	db, err := connectToDatabase()
	if err != nil {
		return false, err
	}
	defer db.Close()

	var exists bool
	query := "SELECT EXISTS(SELECT 1 FROM public.zkpass WHERE address = $1)"

	err = db.QueryRow(query, address).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("failed to check address existence: %w", err)
	}

	return exists, nil
}

func writeJSON(w http.ResponseWriter, status int, payload APIResponse) {
        w.Header().Set("Content-Type", "application/json")
        // Optional hardening:
        // w.Header().Set("Cache-Control", "no-store")
        w.WriteHeader(status)

        enc := json.NewEncoder(w)
        enc.SetEscapeHTML(false)
        _ = enc.Encode(payload)
}

func writeError(w http.ResponseWriter, status int, code, details, message string) {
        writeJSON(w, status, APIResponse{
                Status:  "error",
                Error:   &APIError{Code: code, Details: details},
                Message: message,
        })
}


func handleWhiteCheck(w http.ResponseWriter, r *http.Request) {
	 if r.Method != http.MethodPost {
                writeError(w, http.StatusMethodNotAllowed, "method_not_allowed", "use POST", "Invalid request method")
                return
        }

        var payload RequestPayload
        err := json.NewDecoder(r.Body).Decode(&payload)
        if err != nil {
                writeError(w, http.StatusBadRequest, "invalid_json", err.Error(), "Invalid JSON payload")
                return
        }
        
        addr := strings.TrimSpace(payload.RecipientAddress)
        if addr == "" {
                writeError(w, http.StatusBadRequest, "missing_field", "recipientAddress empty", "recipientAddress is required")
                return
        }

        // Check if address exists in whitelist
        exists, err := checkAddressExists(addr)
        if err != nil {
                writeError(w, http.StatusInternalServerError, "db_error", err.Error(), "Database error")
                return
        }
        msg := "Address is not whitelisted"
        if exists {
                msg = "Address is whitelisted"
        }
        writeJSON(w, http.StatusOK, APIResponse{
                Status: "success",
                Data: map[string]interface{}{
                        "address":     addr,
                        "whitelisted": exists,
                },
                Message: msg,
        })

}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/mint", handlemint)
	mux.HandleFunc("/faucet", handlefaucet)
	mux.HandleFunc("/mint-relayer-wallet", handlemintRelayerWallet)
	mux.HandleFunc("/whitelist/status", handleWhiteCheck)
	// Configure
	c := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"POST", "OPTIONS"},
		AllowedHeaders:   []string{"Content-Type"},
		AllowCredentials: true,
	})

	handler := c.Handler(mux)
	fmt.Println("Server is running on port 6969  with CORS...")
	err := http.ListenAndServe(":6969", handler)
	if err != nil {
		fmt.Printf("Error starting server: %v\n", err)
	}
	// log.Fatal(http.ListenAndServe(":6969", handler))
}
