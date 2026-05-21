package main

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/http"
	"os/exec"
	"regexp"
	"strings"

	_ "github.com/jackc/pgx/v5/stdlib" // postgres driver
	"github.com/rs/cors"
)

const (
        dbHost     = "localhost" // Docker service name
        dbPort     = 5436              // Internal port
        dbUser     = "zkpass"
        dbPassword = "zkpass"
        dbName     = "zkpass"
        // nyksd defaults to $HOME/.nyks; the service often runs as root.
        nyksHome = "/root/.nyks"
        nyksdBin = "/usr/local/bin/nyksd"
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

// parseTxHash extracts transaction hash from command output
func parseTxHash(output string) (string, error) {
        // Use regex for robust extraction
        re := regexp.MustCompile(`(?i)txhash\s*:\s*([A-Fa-f0-9]{32,128})`)
        matches := re.FindStringSubmatch(output)
        
        if len(matches) >= 2 && matches[1] != "" {
                return strings.TrimSpace(matches[1]), nil
        }
        
        // Fallback: line-by-line parsing
        lines := strings.Split(output, "\n")
        for _, line := range lines {
                line = strings.TrimSpace(line)
                lineLower := strings.ToLower(line)
                if strings.HasPrefix(lineLower, "txhash:") {
                        idx := strings.Index(line, ":")
                        if idx >= 0 && idx < len(line)-1 {
                                hash := strings.TrimSpace(line[idx+1:])
                                if len(hash) >= 32 {
                                        return hash, nil
                                }
                        }
                }
        }
        
        return "", fmt.Errorf("transaction hash not found in command output")
}

// runBTCDepositConfirmation runs the specified command with the provided parameters.
func runBTCDepositConfirmation(recipientAddress string) (string, error) {
        tx_id, err := generateRandomHash()
        if err != nil {
                return "", fmt.Errorf("failed to generate random hash: %w", err)
        }
        fmt.Println("confirming btc deposit");
        cmd := exec.Command(
                nyksdBin, "tx", "bridge", "msg-confirm-btc-deposit",
                "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa", // reserve-address
                "50000",                             // deposit-amount
                "50000",                             // block-height
                tx_id,                               // block-hash
                recipientAddress,                    // twilight-deposit-address
                "--from", "validator-v2",
                "--chain-id", "nyks-v2",
                "--keyring-backend", "test",
                "--home", nyksHome,
                "--yes",
        )

        fmt.Println("==============");
        fmt.Println(recipientAddress);
        fmt.Println(cmd);

        // Run the command and capture output
        output, err := cmd.CombinedOutput()
        outputStr := string(output)
        if err != nil {
                return "", fmt.Errorf("failed to execute command: %w\nOutput: %s", err, outputStr)
        }
        fmt.Printf("Command executed successfully:\n%s\n", outputStr)
       // Parse and return transaction hash
        txHash, err := parseTxHash(outputStr)
        if err != nil {
                return "", fmt.Errorf("failed to parse transaction hash: %w", err)
        }
        
        return txHash, nil
}

// runBTCDepositConfirmationRelayerWallet confirms a larger BTC deposit for relayer testing.
func runBTCDepositConfirmationRelayerWallet(recipientAddress string) (string, error) {
        tx_id, err := generateRandomHash()
        if err != nil {
                return "", fmt.Errorf("failed to generate random hash: %w", err)
        }
        fmt.Println("confirming btc deposit");
        cmd := exec.Command(
                nyksdBin, "tx", "bridge", "msg-confirm-btc-deposit",
                "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa",
                "500000000",
                "50000",
                tx_id,
                recipientAddress,
                "--from", "validator-v2",
                "--chain-id", "nyks-v2",
                "--keyring-backend", "test",
                "--home", nyksHome,
                "--yes",
        )

        fmt.Println("==============");
        fmt.Println(recipientAddress);
        fmt.Println(cmd);


        output, err := cmd.CombinedOutput()
        outputStr := string(output)
        if err != nil {
                fmt.Println(err);
                return "", fmt.Errorf("failed to execute command: %w\nOutput: %s", err, outputStr)
        }

        fmt.Printf("Command executed successfully:\n%s\n", outputStr)
        // Parse and return transaction hash
        txHash, err := parseTxHash(outputStr)
        if err != nil {
                return "", fmt.Errorf("failed to parse transaction hash: %w", err)
        }
        
        return txHash, nil
}

func runBankSendCommand(toAddress string) (string, error) {
        // Construct the command
        cmd := exec.Command(
                nyksdBin, "tx", "bank", "send",
                "faucet",
                toAddress,
                "100000nyks",
                "--keyring-backend", "test",
                "--chain-id", "nyks-v2",
                "--home", nyksHome,
                "--yes",
        )

        // Run the command and capture output

        fmt.Println("==============");
        fmt.Println(toAddress);
        fmt.Println(cmd);

        output, err := cmd.CombinedOutput()
        outputStr := string(output)
        if err != nil {
                fmt.Println(err);
                return "", fmt.Errorf("failed to execute command: %w\nOutput: %s", err, outputStr)
        }

        fmt.Printf("Command executed successfully:\n%s\n", outputStr)
        // Parse and return transaction hash
        txHash, err := parseTxHash(outputStr)
        if err != nil {
                return "", fmt.Errorf("failed to parse transaction hash: %w", err)
        }
        
        return txHash, nil
}

func handlemint(w http.ResponseWriter, r *http.Request) {
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

        if payload.RecipientAddress == "" {
                writeError(w, http.StatusBadRequest, "missing_field", "recipientAddress empty", "recipientAddress is required")
                return
        }

        txHash, err := runBTCDepositConfirmation(payload.RecipientAddress)
        if err != nil {
                writeError(w, http.StatusInternalServerError, "command_failed", err.Error(), "Failed to execute command")
                return
        }

        writeJSON(w, http.StatusOK, APIResponse{
                Status: "success",
                Data: map[string]interface{}{
                        "txHash": txHash,
                        "recipientAddress": payload.RecipientAddress,
                },
                Message: "BTC deposit confirmed successfully",
        })
}
func handlemintRelayerWallet(w http.ResponseWriter, r *http.Request) {
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

        if payload.RecipientAddress == "" {
                writeError(w, http.StatusBadRequest, "missing_field", "recipientAddress empty", "recipientAddress is required")
                return
        }

        txHash, err := runBTCDepositConfirmationRelayerWallet(payload.RecipientAddress)
        if err != nil {
                writeError(w, http.StatusInternalServerError, "command_failed", err.Error(), "Failed to execute command")
                return
        }

        writeJSON(w, http.StatusOK, APIResponse{
                Status: "success",
                Data: map[string]interface{}{
                        "txHash": txHash,
                        "recipientAddress": payload.RecipientAddress,
                },
                Message: "BTC deposit confirmed successfully (relayer wallet)",
        })
}
func handlefaucet(w http.ResponseWriter, r *http.Request) {
        fmt.Println("inside handle faucet");
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

        if payload.RecipientAddress == "" {
                writeError(w, http.StatusBadRequest, "missing_field", "recipientAddress empty", "recipientAddress is required")
                return
        }

        txHash, err := runBankSendCommand(payload.RecipientAddress)
        if err != nil {
                writeError(w, http.StatusInternalServerError, "command_failed", err.Error(), "Failed to execute command")
                return
        }

        writeJSON(w, http.StatusOK, APIResponse{
                Status: "success",
                Data: map[string]interface{}{
                        "txHash": txHash,
                        "recipientAddress": payload.RecipientAddress,
                },
                Message: "Tokens sent successfully",
        })
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
                AllowedOrigins:   []string{"https://frontend.twilight.rest", "https://staging-frontend.twilight.rest/"},
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
