package main

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/http"
	"os/exec"

	"github.com/rs/cors"
)

type RequestPayload struct {
	RecipientAddress string `json:"recipientAddress"`
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

	tx_id, err := generateRandomHash()
	if err != nil {
		return fmt.Errorf("failed to generate random hash: %w", err)
	}
	cmd := exec.Command(
		"nyksd", "tx", "bridge", "msg-confirm-btc-deposit", "14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM", "50000", "50000",
		tx_id,
		recipientAddress,
		"twilight14ddyy5rqpycrmpk6spn9zy5attqpqzezp6cf2a",
		"--from",             "validator-self",
                "--chain-id",         "nyks",
                "--keyring-backend",  "test",
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

	tx_id, err := generateRandomHash()
	if err != nil {
		return fmt.Errorf("failed to generate random hash: %w", err)
	}
	cmd := exec.Command(
		"nyksd", "tx", "bridge", "msg-confirm-btc-deposit", "14uEN8abvKA1zgYCpv8MWCUwAMLGBqdZGM", "500000000", "50000",
		tx_id,
		recipientAddress,
		"twilight14ddyy5rqpycrmpk6spn9zy5attqpqzezp6cf2a",
		"--from",             "validator-self",
                "--chain-id",         "nyks",
                "--keyring-backend",  "test",
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
               "--chain-id",        "nyks",
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

func main() {
	 mux := http.NewServeMux()
         mux.HandleFunc("/mint", handlemint)
	 mux.HandleFunc("/faucet", handlefaucet)
	 mux.HandleFunc("/mint-relayer-wallet", handlemintRelayerWallet)
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
//log.Fatal(http.ListenAndServe(":6969", handler))
}
