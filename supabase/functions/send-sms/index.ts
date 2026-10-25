import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { Webhook } from "https://esm.sh/standardwebhooks@1.0.0"

// Required secrets: SEND_SMS_HOOK_SECRET (from Supabase Auth > Hooks, "v1,whsec_..."),
// APITXT_AUTH_KEY; optional APITXT_SENDER_ID, APITXT_TEMPLATE_ID, APITXT_PE_ID.

// 1. Validation Interfaces
interface WebhookPayload {
  user: {
    phone: string;
  };
  sms: {
    otp: string;
  };
}

serve(async (req: Request) => {
  const reqId = crypto.randomUUID();
  console.log(`[${reqId}] Starting APITxT SMS Webhook`);

  try {
    // 2. Authenticate the caller: only Supabase Auth may trigger SMS sends.
    // Without this, anyone could use the endpoint to text arbitrary numbers.
    const hookSecret = Deno.env.get('SEND_SMS_HOOK_SECRET')?.replace('v1,whsec_', '');
    if (!hookSecret) throw new Error('SEND_SMS_HOOK_SECRET is not configured');
    const rawBody = await req.text();
    const headers = Object.fromEntries(req.headers);
    let payload: any;
    try {
      payload = new Webhook(hookSecret).verify(rawBody, headers);
    } catch (_) {
      console.warn(`[${reqId}] Rejected request with invalid webhook signature`);
      return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });
    }

    // 3. Parse and Validate Input
    const phone = payload?.user?.phone;
    const otp = payload?.sms?.otp;

    if (!phone || !otp) {
      console.warn(`[${reqId}] Invalid payload received`);
      return new Response(JSON.stringify({ error: "Missing 'phone' or 'otp' in payload" }), { status: 400 });
    }

    // Strip the '+' sign for APITxT
    const cleanPhone = phone.replace('+', '');

    // 4. Load and Validate Secrets
    const authKey = Deno.env.get('APITXT_AUTH_KEY');
    const senderId = Deno.env.get('APITXT_SENDER_ID') || '';
    const templateId = Deno.env.get('APITXT_TEMPLATE_ID') || '';
    const peId = Deno.env.get('APITXT_PE_ID') || '';

    if (!authKey) throw new Error('APITXT_AUTH_KEY is not configured');

    // 5. Construct message
    const message = `Your IndiaGreen App verification code is: ${otp}. Please do not share this code.`;
    const encodedMessage = encodeURIComponent(message);

    // 6. Construct URL & Timeout handling
    let url = `https://apitxt.com/api/sendMsg?authkey=${authKey}&mobiles=${cleanPhone}&message=${encodedMessage}&route=4`;
    if (senderId) url += `&sender=${senderId}`;
    if (templateId) url += `&template_id=${templateId}`;
    if (peId) url += `&pe_id=${peId}`;

    console.log(`[${reqId}] Sending SMS via APITxT to ***${cleanPhone.slice(-4)}`);

    // Create an AbortController for a 10-second timeout
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000);

    // 7. Execute Request
    const response = await fetch(url, {
      method: 'GET',
      signal: controller.signal,
    });

    clearTimeout(timeoutId);

    const responseText = await response.text();

    if (!response.ok) {
      console.error(`[${reqId}] APITxT HTTP Error ${response.status}: ${responseText}`);
      // Surface the failure so Supabase Auth reports it; never pretend the OTP was sent.
      return new Response(JSON.stringify({ error: 'SMS Gateway Error' }), {
        headers: { "Content-Type": "application/json" },
        status: 502,
      });
    }

    console.log(`[${reqId}] SMS sent successfully. APITxT Response:`, responseText.slice(0, 200));

    return new Response(JSON.stringify({ success: true, message: 'OTP dispatched' }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });

  } catch (e) {
    const error = e as Error;
    if (error.name === 'AbortError') {
      console.error(`[${reqId}] APITxT Request Timed Out`);
      return new Response(JSON.stringify({ error: 'SMS Gateway Timeout' }), { status: 504 });
    }
    console.error(`[${reqId}] Webhook Error:`, error.message);
    return new Response(JSON.stringify({ error: 'Internal Server Error' }), { status: 500 });
  }
});
