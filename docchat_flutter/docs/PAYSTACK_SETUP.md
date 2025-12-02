# Paystack Integration Setup

This document outlines the setup and configuration for Paystack payment integration in the DocChat Flutter app.

## Environment Variables

Add the following variables to your `.env` file:

```env
# Paystack Configuration
PAYSTACK_PUBLIC_KEY=pk_test_xxxxxxxxxxxxx  # Your Paystack public key
PAYSTACK_SECRET_KEY=sk_test_xxxxxxxxxxxxx  # Your Paystack secret key
PAYSTACK_TEST_MODE=true  # Set to 'false' for production
```

### Getting Paystack Keys

1. **Test Mode Keys:**
   - Sign up at https://paystack.com
   - Go to Settings → API Keys & Webhooks
   - Copy your Test Public Key and Test Secret Key

2. **Live Mode Keys:**
   - Complete account verification
   - Switch to Live mode
   - Copy your Live Public Key and Live Secret Key

## Implementation Status

### ✅ Completed
- Paystack service structure created (`lib/core/services/paystack_service.dart`)
- Environment configuration added (`lib/core/config/env_config.dart`)
- Subscription screen UI created with upgrade button
- Subscription repository for fetching subscription status from Supabase

### 🔄 TODO (Next Steps)

1. **Payment Initialization:**
   - Implement `initializePayment()` method in `PaystackService`
   - Create payment initialization API endpoint (or use Paystack Flutter SDK)
   - Handle payment URL opening (web view or browser)

2. **Payment Verification:**
   - Implement `verifyPayment()` method
   - Create webhook endpoint on your backend
   - Update subscription status in Supabase after successful payment

3. **Webhook Handling:**
   - Implement `handleWebhook()` method
   - Set up webhook URL in Paystack dashboard
   - Process payment events (charge.success, charge.failed, etc.)

4. **Paystack Flutter SDK:**
   - Consider using the official Paystack Flutter plugin: `paystack_manager` or `flutter_paystack`
   - Add to `pubspec.yaml`:
     ```yaml
     dependencies:
       flutter_paystack: ^1.0.7
     ```

## Usage Example

```dart
// Initialize payment
final paystackService = PaystackService();
final reference = await paystackService.initializePayment(
  amount: 500000, // ₦5,000.00 in kobo
  email: user.email,
  plan: 'pro_monthly',
  metadata: {
    'user_id': user.id,
    'plan': 'pro',
  },
);

// Verify payment (after user completes payment)
final isSuccessful = await paystackService.verifyPayment(reference);
if (isSuccessful) {
  // Update user subscription in Supabase
}
```

## Supabase Schema

Ensure your Supabase `subscriptions` table has the following structure:

```sql
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    paystack_customer_id TEXT,
    paystack_subscription_id TEXT,
    plan TEXT,  -- 'free' | 'pro'
    status TEXT,  -- 'active' | 'past_due' | 'canceled' | 'incomplete'
    current_period_start TIMESTAMP WITH TIME ZONE,
    current_period_end TIMESTAMP WITH TIME ZONE,
    cancel_at_period_end BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

## Testing

1. Use Paystack test cards:
   - Success: `4084084084084081`
   - Decline: `5060666666666666666`
   - 3DS: `5060666666666666667`

2. Test webhook locally using tools like:
   - ngrok for local webhook testing
   - Paystack's webhook testing dashboard

## Security Notes

- Never expose secret keys in client-side code
- Always verify webhook signatures
- Use HTTPS for webhook endpoints
- Implement proper error handling and logging

