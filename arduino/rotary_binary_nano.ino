constexpr uint8_t pin_rot_a = 2;
constexpr uint8_t pin_rot_b = 3;

uint8_t x = 0;
int32_t p = 0;

void intCallback()
{
  uint8_t y = PIND;
  uint8_t z = ((y >> (pin_rot_a - 1)) & 2) | ((y >> (pin_rot_b)) & 1);
  uint8_t d = x ^ z;
  x = ((y >> (pin_rot_b - 1)) & 2) | ((y >> (pin_rot_a)) & 1);
  p += d;
  p -= 3 * (d >> 1);
  Serial.write((uint8_t*)&p, 4);
}

void setup() {
  pinMode(pin_rot_a, INPUT_PULLUP);
  pinMode(pin_rot_b, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(pin_rot_a), intCallback, CHANGE);
  attachInterrupt(digitalPinToInterrupt(pin_rot_b), intCallback, CHANGE);
  Serial.begin(9600);
}

void loop() {
  delay(1000);
}
