# UI/UX Design Specs: AI Travel Concierge

## 1. Design Direction
- **Product vision**: AI travel concierge cho nhóm người dùng muốn lên kế hoạch du lịch nhanh, tin cậy, và có cảm giác được “chăm sóc riêng”.
- **Experience theme**: "Curated Escape" - sang trọng hiện đại, ít nhiễu, nhấn mạnh cảm giác premium nhưng vẫn dễ thao tác.
- **Core design principles**:
  - Quyết định nhanh: người dùng luôn nhìn thấy next step rõ ràng.
  - Trust-first: hiển thị dữ liệu chuyến đi, giá, nguồn xác nhận, trạng thái khả dụng.
  - Personal but calm: cá nhân hóa mạnh, không làm UI quá phô trương.
  - Mobile-priority: hành vi booking và xem itinerary ưu tiên mobile trước.

## 2. Target Users
- **Busy explorer**: cần AI gom lịch trình nhanh theo ngân sách và thời gian rảnh.
- **Premium traveler**: ưu tiên trải nghiệm, khách sạn tốt, phương án di chuyển mượt.
- **Delegator**: không muốn tự so sánh hàng chục tab, chỉ muốn chọn trong vài phương án tốt.

## 3. Primary User Flow
1. User vào Home và mô tả nhu cầu chuyến đi.
2. AI tạo 3 itinerary options theo phong cách khác nhau.
3. User mở chi tiết itinerary, xem flight, hotel, activity, tổng chi phí.
4. User tinh chỉnh bằng prompt nhanh hoặc filter.
5. User xác nhận booking.
6. System trả kết quả thành công, voucher, và file itinerary.

## 4. Information Architecture
- **Home / Prompt Entry**
- **Trip Preferences**
- **AI Results / Itinerary Options**
- **Itinerary Detail**
- **Booking Review**
- **Payment Success**
- **My Trips / Saved Plans** (future-ready)

## 5. Visual Style
- **Mood**: luxury, cinematic, polished.
- **Color story**: midnight base + warm sand + champagne gold.
- **Surface style**: layered cards, soft blur, subtle glow, high contrast typography.
- **Imagery**: destination hero photography với overlay gradient đậm để giữ khả năng đọc.

## 6. Design Tokens

### 6.1 Color Tokens
- `bg.canvas`: `#0E1116`
- `bg.surface`: `#151A21`
- `bg.elevated`: `#1B222C`
- `bg.glass`: `rgba(255,255,255,0.08)`
- `stroke.soft`: `rgba(255,255,255,0.10)`
- `stroke.strong`: `rgba(255,255,255,0.18)`
- `text.primary`: `#F5F1E8`
- `text.secondary`: `#C8C1B3`
- `text.muted`: `#91897B`
- `brand.primary`: `#D6B36A`
- `brand.secondary`: `#F3E1B0`
- `accent.success`: `#4CAF88`
- `accent.warning`: `#F2B95E`
- `accent.error`: `#D96B6B`
- `accent.info`: `#7EB6FF`

### 6.2 Typography
- **Display / Headline**: `Playfair Display`
- **Body / UI**: `Inter`

Type scale:
- `Display 56/64 Semibold`
- `H1 40/48 Semibold`
- `H2 32/40 Semibold`
- `H3 24/32 Medium`
- `Title 20/28 Medium`
- `Body 16/24 Regular`
- `Body Small 14/20 Regular`
- `Caption 12/16 Medium`

### 6.3 Spacing
- Base grid: `8pt`
- Scale: `4, 8, 12, 16, 24, 32, 40, 48, 64, 80`

### 6.4 Radius
- `sm`: `12`
- `md`: `16`
- `lg`: `24`
- `xl`: `32`
- `pill`: `999`

### 6.5 Shadow & Blur
- `shadow.soft`: `0 12 40 rgba(0,0,0,0.24)`
- `shadow.glow`: `0 0 32 rgba(214,179,106,0.18)`
- `blur.glass`: `backdrop-blur 20`

## 7. Responsive Layout

### 7.1 Breakpoints
- Mobile: `390 x 844`
- Tablet: `768 x 1024`
- Desktop: `1440 x 1024`

### 7.2 Grid
- Mobile: 4 columns, margin `20`, gutter `12`
- Tablet: 8 columns, margin `32`, gutter `16`
- Desktop: 12 columns, margin `80`, gutter `24`

## 8. Atomic Design System

### 8.1 Atoms
- Primary button
- Secondary button
- Ghost button
- Text field
- Search / prompt input
- Filter chip
- Status badge
- Price tag
- Star rating
- Icon set: plane, hotel, map pin, calendar, wallet, sparkle, edit, heart

### 8.2 Molecules
- Prompt bar = text input + AI submit button
- Destination chip = icon + label + remove action
- Preference selector = label + segmented options
- KPI item = icon + meta text
- Review snippet = avatar + rating + text

### 8.3 Organisms
- Hero search section
- Itinerary recommendation card
- Flight summary card
- Hotel summary card
- Day plan accordion
- Booking breakdown panel
- Payment success panel

## 9. Screen-by-Screen Figma Spec

### 9.1 Screen 01: Home / Prompt Entry
- **Goal**: thu hút và giúp user bắt đầu trong dưới 10 giây.
- **Layout**:
  - Top nav: logo, `Explore`, `Saved Trips`, avatar.
  - Hero section trái: headline lớn “Where should we take you next?”
  - Hero section phải: visual card stack với ảnh destination blur.
  - Prompt panel: textarea, quick prompts, budget chip, date range, travel style.
- **Primary CTA**: `Generate My Trip`
- **Secondary CTA**: `Browse Inspirations`
- **Microcopy**:
  - Placeholder: `3 days in Da Lat, budget 5 million VND, romantic and scenic`
  - Helper text: `Flights, hotels, and day plans will be optimized together`

### 9.2 Screen 02: AI Results / Itinerary Selection
- **Goal**: cho user so sánh 3 hướng itinerary rõ ràng.
- **Layout**:
  - Sticky header với trip summary.
  - 3 recommendation cards dạng horizontal scroll trên mobile, 3-column trên desktop.
  - Mỗi card gồm:
    - Theme title: `The Explorer`, `The Relaxist`, `The Gourmet`
    - Cover image
    - 3 key highlights
    - Total estimated cost
    - Confidence badge / availability
    - CTA `View Details`
- **Interaction**:
  - Hover: tăng elevation và glow nhẹ.
  - Selected state: viền gold + badge `Best Match`.

### 9.3 Screen 03: Itinerary Detail
- **Goal**: giúp user hiểu lịch trình đủ sâu để ra quyết định.
- **Layout desktop**:
  - Left 8 columns: timeline chuyến đi theo ngày.
  - Right 4 columns sticky: cost, transport, hotel, CTA booking.
- **Sections**:
  - Trip overview
  - Flight option
  - Hotel block
  - Daily agenda
  - Dining recommendations
  - Weather and travel notes
  - Feedback actions: thumbs up/down, `Refine this plan`
- **Key CTA**: `Book This Plan`
- **Secondary action**: `Ask AI to Adjust`

### 9.4 Screen 04: Booking Review
- **Goal**: xác nhận lại trước thanh toán.
- **Layout**:
  - Summary card: destination, dates, travelers
  - Included items list
  - Pricing breakdown: flight, hotel, activities, fees
  - Contact form compact
  - Payment CTA cố định cuối màn hình mobile
- **Trust UI**:
  - Secure payment badge
  - Refund policy link
  - Agent support note

### 9.5 Screen 05: Success / Voucher
- **Goal**: tạo cảm giác hoàn tất trọn vẹn, thúc đẩy retention.
- **Layout**:
  - Success illustration hoặc premium confetti glow
  - Booking reference
  - Download actions:
    - `Download Itinerary ZIP`
    - `Add to Calendar`
    - `Share Trip`
  - Suggested next action: `Plan Another Getaway`

## 10. Key Components

### 10.1 Itinerary Card
- Image ratio `4:5`
- Padding `20`
- Radius `24`
- Overlay gradient từ transparent sang `#0E1116`
- Meta rows:
  - Duration
  - Budget
  - Travel tone
  - Availability

### 10.2 Prompt Composer
- Multiline input min-height `120`
- Quick suggestions dạng chips
- Voice input placeholder cho phase sau
- AI submit button nổi bật bằng gradient gold

### 10.3 Booking Summary Sidebar
- Sticky on desktop
- Tổng giá nằm trên cùng, font lớn
- Breakdown collapsible
- CTA full width
- Policy links đặt cuối card

## 11. Interaction Design
- Page transition: fade + rise `240ms`
- Card hover: scale `1.01`, shadow tăng nhẹ
- Button press: darken `8%`
- Accordion expand: `200ms ease-out`
- Loading state:
  - shimmer card placeholders
  - progress message theo bước:
    - `Finding flights`
    - `Checking hotels`
    - `Building your itinerary`

## 12. Accessibility
- Contrast text/body tối thiểu `4.5:1`
- Tất cả CTA chính phải có label rõ nghĩa, không dùng chỉ icon
- Focus state hiển thị rõ bằng outline sáng
- Tap target tối thiểu `44x44`
- Không dùng chỉ màu để biểu đạt status

## 13. Figma File Structure
- **Page 1 - Cover**
  - Project name
  - Version
  - Design direction snapshot
- **Page 2 - Foundations**
  - Color styles
  - Typography styles
  - Grid
  - Effects
- **Page 3 - Components**
  - Buttons
  - Inputs
  - Chips
  - Cards
  - Badges
  - Nav items
- **Page 4 - Screens Desktop**
  - Home
  - Results
  - Detail
  - Booking
  - Success
- **Page 5 - Screens Mobile**
  - Home
  - Results
  - Detail
  - Booking
  - Success
- **Page 6 - Prototype**
  - Main journey flow
  - Happy path interactions
  - Refine itinerary branch

## 14. Suggested Figma Components Naming
- `Button / Primary / Default`
- `Button / Primary / Hover`
- `Button / Secondary / Default`
- `Input / Prompt / Default`
- `Card / Itinerary / Default`
- `Card / Itinerary / Selected`
- `Sidebar / Booking Summary`
- `Section / Day Agenda`

## 15. Prototype Flow in Figma
1. Home -> click `Generate My Trip`
2. Loading overlay -> Results
3. Select itinerary -> Detail
4. Click `Book This Plan` -> Booking Review
5. Click `Confirm & Pay` -> Success
6. Click `Download Itinerary ZIP`

## 16. Handoff Notes
- Developer nên ưu tiên dựng component library trước page layout.
- Trạng thái loading và empty state quan trọng vì đây là sản phẩm AI.
- Nếu cần giảm effort MVP, có thể cắt `Saved Trips` và `Share Trip` sang phase sau.
- Bản thiết kế nên được hoàn thành trước ở mobile và desktop, tablet chỉ cần adaptive layout.

## 17. Low-Fidelity Wireframe

### 17.1 Desktop Frame List

#### Frame D1: Home / Prompt Entry
- Frame size: `1440 x 1024`
- Grid: `12 columns`, margin `80`, gutter `24`
- Structure:
  - Top nav height `88`
  - Hero content split `7/5`
  - Prompt panel placed under headline, width `100%` of left column group
  - Visual stack card block on right with 2-3 overlapping destination cards
- Wireframe blocks:
  - `[Logo] [Explore] [Saved Trips] .................. [Profile]`
  - `[Headline]`
  - `[Subtext]`
  - `[Prompt textarea.....................................]`
  - `[Budget chip] [Date chip] [Travel style chip] [Travelers chip]`
  - `[Primary CTA] [Secondary CTA]`
  - `[Visual card 1]`
  - `[Visual card 2]`
  - `[Visual card 3]`

#### Frame D2: AI Loading State
- Frame size: `1440 x 1024`
- Keep same nav and page shell as Home
- Center modal or overlay block:
  - `[AI orb / loader]`
  - `Finding flights`
  - `Checking hotels`
  - `Building your itinerary`
- Skeleton placeholders below for 3 itinerary cards

#### Frame D3: Results / Itinerary Selection
- Frame size: `1440 x 1200`
- Structure:
  - Sticky summary header
  - 3 cards in equal width columns
  - Filter row above cards
- Wireframe blocks:
  - `[Back] [Trip summary..................................] [Edit search]`
  - `[Filter: Budget] [Filter: Vibe] [Filter: Hotel class]`
  - `[Card A] [Card B - selected] [Card C]`
- Card anatomy:
  - `[Cover image]`
  - `[Theme title]`
  - `[3 highlights]`
  - `[Meta row]`
  - `[Estimated price]`
  - `[View Details]`

#### Frame D4: Itinerary Detail
- Frame size: `1440 x 1400`
- Structure:
  - Left `8 columns`: content stack
  - Right `4 columns`: sticky booking sidebar
- Wireframe blocks left:
  - `[Hero image banner]`
  - `[Trip title + tags + rating]`
  - `[Overview KPI row]`
  - `[Flight summary card]`
  - `[Hotel summary card]`
  - `[Day 1 accordion]`
  - `[Day 2 accordion]`
  - `[Day 3 accordion]`
  - `[Dining recommendations]`
  - `[Travel notes]`
  - `[Feedback row]`
- Wireframe blocks right:
  - `[Total price]`
  - `[Included items]`
  - `[Book This Plan]`
  - `[Ask AI to Adjust]`
  - `[Support note]`

#### Frame D5: Booking Review
- Frame size: `1440 x 1200`
- Structure:
  - Left `7 columns`: booking forms and included details
  - Right `5 columns`: price and secure payment panel
- Wireframe blocks:
  - `[Trip summary card]`
  - `[Traveler info form]`
  - `[Contact info form]`
  - `[Included list]`
  - `[Policy notice]`
  - Right panel:
    - `[Price breakdown]`
    - `[Promo code input]`
    - `[Confirm & Pay button]`
    - `[Secure payment note]`

#### Frame D6: Success / Voucher
- Frame size: `1440 x 1024`
- Structure:
  - Centered success stack, max width `720`
- Wireframe blocks:
  - `[Success icon / illustration]`
  - `[Success headline]`
  - `[Booking reference]`
  - `[Trip summary mini card]`
  - `[Download ZIP] [Add to Calendar]`
  - `[Share Trip]`
  - `[Plan Another Getaway]`

### 17.2 Mobile Frame List

#### Frame M1: Home
- Frame size: `390 x 844`
- Structure:
  - Top app bar `64`
  - Hero text
  - Prompt composer full width
  - Quick chips scroll horizontally
  - CTA sticky near bottom safe area
- Block order:
  - `[Logo] [Menu/Profile]`
  - `[Headline]`
  - `[Subtext]`
  - `[Prompt textarea]`
  - `[Quick chips row scroll]`
  - `[Budget/date/style selectors]`
  - `[Generate My Trip]`

#### Frame M2: Results
- Frame size: `390 x 844`
- Structure:
  - Sticky compact summary header
  - Cards in horizontal carousel
  - CTA on selected card
- Block order:
  - `[Back] [Trip summary]`
  - `[Filter chips row]`
  - `[Card 1]`
  - `[Card 2 selected]`
  - `[Card 3]`

#### Frame M3: Detail
- Frame size: `390 x 1200`
- Structure:
  - Single column
  - Sticky bottom bar with price + CTA
- Block order:
  - `[Hero image]`
  - `[Title + tags]`
  - `[Overview KPIs]`
  - `[Flight card]`
  - `[Hotel card]`
  - `[Day accordions]`
  - `[Dining]`
  - `[Travel notes]`
  - Bottom sticky:
    - `[Price] [Book This Plan]`

#### Frame M4: Booking
- Frame size: `390 x 1024`
- Block order:
  - `[Trip summary]`
  - `[Traveler form]`
  - `[Contact form]`
  - `[Price breakdown accordion]`
  - `[Confirm & Pay]`
  - `[Secure payment note]`

#### Frame M5: Success
- Frame size: `390 x 844`
- Block order:
  - `[Success icon]`
  - `[Headline]`
  - `[Booking reference]`
  - `[Download ZIP]`
  - `[Add to Calendar]`
  - `[Plan Another Getaway]`

## 18. Hi-Fidelity Copy-Ready Content

### 18.1 Global Navigation Copy
- Logo: `Asteria Travel`
- Nav item 1: `Explore`
- Nav item 2: `Saved Trips`
- Nav item 3: `Concierge Support`
- Profile entry: `My Account`

### 18.2 Home Screen Copy

#### Hero
- Eyebrow: `AI-Powered Luxury Planning`
- Headline: `Where should we take you next?`
- Subheadline: `Tell us your budget, mood, and timing. Your concierge will build a complete trip with flights, stays, and daily plans in seconds.`

#### Prompt Composer
- Label: `Describe your ideal trip`
- Placeholder: `3 days in Da Lat, 2 travelers, 5 million VND, scenic cafes, local food, and a boutique hotel`
- Helper text: `We will combine transport, hotel, activities, and pacing into one itinerary.`

#### Quick Prompt Chips
- `Weekend in Da Lat`
- `Food trip in Bangkok`
- `Romantic beach escape`
- `Family trip under budget`

#### Preference Labels
- Budget label: `Budget`
- Budget placeholder: `5,000,000 VND`
- Dates label: `Dates`
- Dates placeholder: `Apr 12 - Apr 14`
- Style label: `Travel Style`
- Style value options:
  - `Relaxed`
  - `Balanced`
  - `Explorer`
- Travelers label: `Travelers`
- Travelers value: `2 Adults`

#### CTAs
- Primary CTA: `Generate My Trip`
- Secondary CTA: `Browse Inspirations`

### 18.3 Loading State Copy
- Title: `Crafting your journey`
- Step 1: `Finding the best transport options`
- Step 2: `Checking stays that match your style`
- Step 3: `Building a day-by-day itinerary`
- Footer note: `This usually takes less than 10 seconds`

### 18.4 Results Screen Copy

#### Summary Header
- Title format: `3 days in Da Lat for 2 travelers`
- Meta line: `Budget target 5,000,000 VND • Departing from Ho Chi Minh City`
- Edit action: `Edit Search`

#### Filter Labels
- `Budget`
- `Trip Vibe`
- `Hotel Class`
- `Transport`

#### Card A
- Theme: `The Explorer`
- Tagline: `Packed with viewpoints, local food, and active mornings`
- Highlights:
  - `Sunrise at Langbiang`
  - `Street food crawl`
  - `Compact schedule, max coverage`
- Meta:
  - `3 Days`
  - `Boutique Stay`
  - `Fast-paced`
- Price: `From 4,850,000 VND`
- CTA: `View Details`

#### Card B
- Theme: `The Relaxist`
- Badge: `Best Match`
- Tagline: `Scenic cafes, easy pacing, and a restful boutique experience`
- Highlights:
  - `Lakeview slow mornings`
  - `Curated dining picks`
  - `Balanced travel time`
- Meta:
  - `3 Days`
  - `Boutique Premium`
  - `Balanced`
- Price: `From 5,120,000 VND`
- CTA: `View Details`

#### Card C
- Theme: `The Gourmet`
- Tagline: `Destination-first planning built around memorable food moments`
- Highlights:
  - `Chef-picked local dining`
  - `Night market route`
  - `Flexible midday breaks`
- Meta:
  - `3 Days`
  - `Design Hotel`
  - `Food-focused`
- Price: `From 5,340,000 VND`
- CTA: `View Details`

### 18.5 Itinerary Detail Copy

#### Hero Block
- Title: `The Relaxist`
- Subtitle: `A calm, premium 3-day Da Lat escape designed around views, food, and slow travel.`
- Tags:
  - `Best Match`
  - `Boutique Premium`
  - `Balanced Pace`

#### KPI Row
- KPI 1 label: `Estimated Total`
- KPI 1 value: `5,120,000 VND`
- KPI 2 label: `Travel Time`
- KPI 2 value: `3 days / 2 nights`
- KPI 3 label: `Availability`
- KPI 3 value: `Flights and hotel available`
- KPI 4 label: `AI Confidence`
- KPI 4 value: `92% match`

#### Flight Card
- Section title: `Recommended Transport`
- Route: `Ho Chi Minh City -> Da Lat`
- Option details: `Morning departure • 1h flight • 1 checked bag`
- Confidence note: `Live availability verified`

#### Hotel Card
- Section title: `Stay`
- Hotel name: `Lakeside Atelier Hotel`
- Description: `Boutique stay with soft interiors, central access, and quiet evening atmosphere.`
- Meta line: `2 nights • Breakfast included • 4.7 guest rating`

#### Day Agenda
- Day 1 title: `Arrival and slow city entry`
- Day 1 items:
  - `Airport transfer and hotel check-in`
  - `Late lunch at a local garden cafe`
  - `Sunset walk around Xuan Huong Lake`
- Day 2 title: `Scenic highlights and signature dining`
- Day 2 items:
  - `Leisure breakfast with valley view`
  - `Curated sightseeing route`
  - `Dinner reservation at a contemporary Vietnamese restaurant`
- Day 3 title: `Easy final morning and departure`
- Day 3 items:
  - `Coffee stop and souvenir window`
  - `Flexible buffer before airport`
  - `Return flight`

#### Supporting Sections
- Dining title: `Recommended Dining`
- Dining copy: `Three handpicked venues based on ambiance, consistency, and route efficiency.`
- Notes title: `Travel Notes`
- Notes copy: `Pack a light jacket for evening weather. The itinerary keeps commute times short to reduce fatigue.`

#### Detail Actions
- Primary CTA: `Book This Plan`
- Secondary CTA: `Ask AI to Adjust`
- Feedback positive: `This feels right`
- Feedback negative: `Show me another direction`

### 18.6 Booking Review Copy

#### Header
- Title: `Review your booking`
- Subtitle: `One last check before we confirm your trip.`

#### Summary Card
- Destination: `Da Lat, Vietnam`
- Dates: `Apr 12 - Apr 14`
- Travelers: `2 Adults`
- Plan: `The Relaxist`

#### Form Labels
- Traveler section title: `Traveler Information`
- Full name: `Full Name`
- Email: `Email Address`
- Phone: `Phone Number`
- Special requests: `Special Requests`
- Placeholder special requests: `Dietary needs, hotel preferences, or accessibility notes`

#### Price Breakdown
- Flight: `1,860,000 VND`
- Hotel: `2,400,000 VND`
- Activities: `560,000 VND`
- Service Fee: `300,000 VND`
- Total: `5,120,000 VND`

#### Payment Panel
- Promo field label: `Promo Code`
- Promo placeholder: `Enter code`
- Primary CTA: `Confirm & Pay`
- Trust note: `Payments are encrypted and your booking details are securely stored.`
- Support note: `Need help? A concierge agent can assist before payment.`

### 18.7 Success Screen Copy
- Eyebrow: `Booking Confirmed`
- Headline: `Your getaway is ready`
- Body: `Your itinerary, booking summary, and travel voucher are prepared. You can download everything now or return later from Saved Trips.`
- Booking reference label: `Booking Reference`
- Booking reference value: `ATC-24819-DL`
- Primary CTA: `Download Itinerary ZIP`
- Secondary CTA: `Add to Calendar`
- Tertiary CTA: `Share Trip`
- Next-trip CTA: `Plan Another Getaway`

## 19. Figma Build Instructions
- Tạo `Section` riêng cho từng frame: `D1 Home`, `D2 Loading`, `D3 Results`, `D4 Detail`, `D5 Booking`, `D6 Success`, `M1-M5`.
- Dựng low-fi trước bằng grayscale với 3 màu:
  - `#121212`
  - `#2A2A2A`
  - `#EAEAEA`
- Sau khi chốt layout, map sang token màu ở Mục 6.
- Dùng Auto Layout cho:
  - navigation
  - prompt composer
  - itinerary cards
  - KPI row
  - booking sidebar
  - button groups
- Tạo component variant tối thiểu cho:
  - button `default / hover / disabled`
  - card `default / selected / loading`
  - chip `default / active`
  - accordion `collapsed / expanded`

## 20. Suggested Figma Layer Naming
- `Frame / Desktop / Home`
- `Frame / Desktop / Results`
- `Frame / Desktop / Detail`
- `Frame / Desktop / Booking`
- `Frame / Desktop / Success`
- `Frame / Mobile / Home`
- `Frame / Mobile / Results`
- `Component / Card / Itinerary`
- `Component / Input / Prompt`
- `Component / Sidebar / Booking`

## 21. Detailed Figma Component Spec

### 21.1 Button Component

#### Component Name
- `Button / Primary`
- `Button / Secondary`
- `Button / Ghost`
- `Button / Tertiary`

#### Purpose
- Dùng cho toàn bộ hành động chính, phụ, hoặc contextual action trong flow AI Travel Concierge.

#### Structure
- Container
  - Leading icon optional
  - Label
  - Trailing icon optional

#### Auto Layout
- Direction: horizontal
- Align: center
- Gap:
  - icon + text: `8`
- Padding:
  - Desktop default: `14 top/bottom`, `20 left/right`
  - Mobile default: `16 top/bottom`, `20 left/right`

#### Sizing
- Height:
  - Small: `40`
  - Medium: `48`
  - Large: `56`
- Width:
  - Hug content
  - Fill container when CTA block
- Radius:
  - Default: `16`
  - Pill option: `999`

#### Typography
- Label style:
  - Default: `Body Small 14/20 Medium`
  - Large: `Body 16/24 Medium`

#### Variants
- Hierarchy:
  - `Primary`
  - `Secondary`
  - `Ghost`
  - `Danger`
- Size:
  - `S`
  - `M`
  - `L`
- State:
  - `Default`
  - `Hover`
  - `Pressed`
  - `Focus`
  - `Disabled`
  - `Loading`
- Icon:
  - `None`
  - `Leading`
  - `Trailing`
  - `Both`

#### Visual Spec: Primary
- Background:
  - Default: gradient `#F3E1B0 -> #D6B36A`
  - Hover: gradient tăng sáng `4%`
  - Pressed: gradient tối `8%`
  - Disabled: `rgba(214,179,106,0.35)`
- Text color:
  - Default: `#1A1A1A`
  - Disabled: `rgba(26,26,26,0.45)`
- Border: none
- Shadow:
  - Default: `shadow.glow`
  - Hover: `0 0 40 rgba(214,179,106,0.24)`
  - Pressed: `0 0 20 rgba(214,179,106,0.12)`

#### Visual Spec: Secondary
- Background: `rgba(255,255,255,0.06)`
- Border: `1px stroke.soft`
- Text: `text.primary`
- Hover background: `rgba(255,255,255,0.10)`
- Pressed background: `rgba(255,255,255,0.14)`

#### Visual Spec: Ghost
- Background: transparent
- Border: none
- Text: `brand.secondary`
- Hover background: `rgba(255,255,255,0.06)`
- Pressed background: `rgba(255,255,255,0.10)`

#### Loading State
- Label replaced with:
  - spinner + `Generating...`
  - spinner size `16`
- Disable pointer interaction

#### Usage Rules
- Chỉ dùng `Primary` một lần trong mỗi viewport chính.
- `Ghost` phù hợp cho inline action hoặc supporting navigation.
- Trên mobile sticky CTA, luôn dùng `Primary / L / Fill`.

### 21.2 Input Component

#### Component Name
- `Input / Text`
- `Input / Prompt`
- `Input / Select`
- `Input / Date`

#### Structure
- Label
- Field container
  - Leading icon optional
  - Placeholder / entered text
  - Trailing affordance optional
- Supporting text
- Error text optional

#### Auto Layout
- Direction: vertical
- Gap:
  - label to field: `8`
  - field to helper: `6`

#### Field Sizing
- Text input height: `48`
- Prompt input min-height: `120`
- Radius: `16`
- Padding:
  - Single line: `12 vertical`, `16 horizontal`
  - Prompt: `16 all sides`

#### Variants
- Type:
  - `Text`
  - `Prompt`
  - `Select`
  - `Date`
- State:
  - `Default`
  - `Hover`
  - `Focus`
  - `Filled`
  - `Error`
  - `Disabled`

#### Visual Spec
- Background: `rgba(255,255,255,0.05)`
- Border:
  - Default: `1px stroke.soft`
  - Focus: `1px brand.primary`
  - Error: `1px accent.error`
- Text entered: `text.primary`
- Placeholder: `text.muted`
- Helper text: `text.secondary`
- Focus shadow: `0 0 0 4 rgba(214,179,106,0.12)`

#### Prompt Composer Specifics
- Includes optional chip row below
- Submit button attached as separate component on right or bottom
- Max width desktop: `640`
- Full width mobile

### 21.3 Chip Component

#### Component Name
- `Chip / Filter`
- `Chip / Suggestion`
- `Chip / Selected`

#### Structure
- Optional icon
- Label
- Optional close icon

#### Sizing
- Height: `36`
- Padding: `10 vertical`, `14 horizontal`
- Radius: `999`

#### Variants
- Type:
  - `Default`
  - `Active`
  - `Dismissible`
- State:
  - `Default`
  - `Hover`
  - `Pressed`

#### Visual Spec
- Default background: `rgba(255,255,255,0.06)`
- Active background: `rgba(214,179,106,0.16)`
- Active border: `1px rgba(214,179,106,0.36)`
- Text:
  - Default: `text.secondary`
  - Active: `brand.secondary`

### 21.4 Itinerary Card Component

#### Component Name
- `Card / Itinerary`

#### Purpose
- Trình bày một phương án trip hoàn chỉnh trong màn hình kết quả.

#### Structure
- Card container
  - Cover image area
  - Top badge row
  - Title group
  - Highlight list
  - Meta row
  - Price block
  - CTA button

#### Auto Layout
- Direction: vertical
- Gap: `16`
- Padding: `20`
- Radius: `24`

#### Sizing
- Desktop width:
  - `Full column`
  - Recommended min width `368`
- Mobile width:
  - `312`
- Cover image:
  - Ratio `4:5`
  - Radius `20`

#### Variants
- State:
  - `Default`
  - `Hover`
  - `Selected`
  - `Loading`
- Emphasis:
  - `Standard`
  - `Best Match`

#### Visual Spec
- Background: `bg.surface`
- Border:
  - Default: `1px stroke.soft`
  - Hover: `1px stroke.strong`
  - Selected: `1px brand.primary`
- Shadow:
  - Default: `shadow.soft`
  - Hover: elevated + glow
  - Selected: `shadow.soft + shadow.glow`

#### Content Rules
- Title max 2 lines
- Tagline max 2 lines
- Highlight list fixed 3 items
- Meta row 3 items max
- Price emphasized with `Title 20/28 Medium`

#### Best Match Variant
- Badge label: `Best Match`
- Badge color: `brand.primary` background at `18%`
- Small star icon allowed

#### Loading Variant
- Replace image and text blocks with skeleton rectangles
- CTA hidden

### 21.5 Flight Summary Card

#### Component Name
- `Card / Flight Summary`

#### Structure
- Header row:
  - Section title
  - Availability badge
- Route row:
  - Origin
  - plane icon
  - Destination
- Meta row:
  - departure time
  - duration
  - baggage
- Supporting note

#### Sizing
- Padding: `20`
- Radius: `20`
- Min height: `156`

#### Visual Spec
- Background: `bg.elevated`
- Border: `1px stroke.soft`

### 21.6 Hotel Summary Card

#### Component Name
- `Card / Hotel Summary`

#### Structure
- Thumbnail image `96 x 96`
- Hotel info stack
  - Name
  - Description
  - Meta row
  - Optional rating
- Action link optional

#### Auto Layout
- Direction: horizontal desktop
- Direction mobile: vertical if width < `320`
- Gap: `16`
- Padding: `20`

#### Visual Spec
- Background: `bg.elevated`
- Radius: `20`
- Border: `1px stroke.soft`

### 21.7 KPI Item Component

#### Component Name
- `Data / KPI Item`

#### Structure
- Icon container
- Label
- Value

#### Sizing
- Min width: `140`
- Padding: `16`
- Radius: `16`

#### Visual Spec
- Background: `rgba(255,255,255,0.04)`
- Border: `1px stroke.soft`

### 21.8 Badge Component

#### Component Name
- `Badge / Status`
- `Badge / Highlight`

#### Sizing
- Height: `28`
- Padding: `6 vertical`, `10 horizontal`
- Radius: `999`

#### Variants
- `Success`
- `Warning`
- `Error`
- `Info`
- `Brand`

#### Colors
- Success: bg `rgba(76,175,136,0.16)`, text `#8FE0BD`
- Warning: bg `rgba(242,185,94,0.16)`, text `#F2C980`
- Error: bg `rgba(217,107,107,0.16)`, text `#F3A2A2`
- Info: bg `rgba(126,182,255,0.16)`, text `#A9CEFF`
- Brand: bg `rgba(214,179,106,0.16)`, text `brand.secondary`

### 21.9 Booking Summary Sidebar

#### Component Name
- `Sidebar / Booking Summary`

#### Purpose
- Sticky confirmation panel trên màn Detail và Booking.

#### Structure
- Container
  - Total price block
  - Meta summary
  - Divider
  - Included items list
  - Divider
  - Price breakdown accordion optional
  - Primary CTA
  - Secondary CTA
  - Trust note
  - Support note

#### Auto Layout
- Direction: vertical
- Gap: `16`
- Padding: `24`

#### Sizing
- Desktop width: `100%` within 4-column rail
- Recommended max width standalone: `360`
- Radius: `24`
- Sticky offset from top: `104`

#### Visual Spec
- Background: linear blend of `bg.elevated` and `bg.glass`
- Border: `1px stroke.soft`
- Shadow: `shadow.soft`
- Backdrop blur: `20`

#### Typography
- Price label: `Body Small 14/20`
- Price value: `H3 24/32 Medium`
- Meta and note: `Caption` or `Body Small`

#### CTA Rules
- Primary CTA always fill width
- Secondary CTA can be ghost style full width or inline beneath

#### Content Rules
- Included items max visible without collapse: `4`
- Support note placed at bottom, muted hierarchy

### 21.10 Accordion Component

#### Component Name
- `Accordion / Day Agenda`
- `Accordion / Price Breakdown`

#### Purpose
- Quản lý nội dung nhiều tầng trong itinerary day plan hoặc pricing details.

#### Structure
- Header row
  - Leading label
  - Optional sublabel
  - Chevron icon
- Body
  - Divider optional
  - Content block

#### Auto Layout
- Direction: vertical
- Header padding: `16`
- Body padding: `0 16 16 16`

#### Variants
- Type:
  - `Agenda`
  - `Price`
- State:
  - `Collapsed`
  - `Expanded`
  - `Hover`

#### Visual Spec
- Background:
  - Default: `rgba(255,255,255,0.04)`
  - Expanded: `rgba(255,255,255,0.06)`
- Border: `1px stroke.soft`
- Radius: `18`

#### Chevron Behavior
- Collapsed: `0deg`
- Expanded: `180deg`
- Animation: `200ms ease-out`

#### Day Agenda Content Pattern
- Time label
- Activity title
- Supporting note
- Travel transfer mini row optional

#### Price Breakdown Content Pattern
- Line item label
- Amount
- Final total row emphasized

### 21.11 Review Snippet Component

#### Component Name
- `Card / Review Snippet`

#### Structure
- Avatar
- Reviewer name
- Rating row
- Review text

#### Sizing
- Padding: `16`
- Radius: `16`

#### Usage
- Có thể đặt ở Home hoặc Detail để tăng trust.

### 21.12 Empty State Component

#### Component Name
- `State / Empty`

#### Structure
- Illustration or icon
- Title
- Supporting text
- Primary CTA optional

#### Use Cases
- Không tìm thấy itinerary
- Không có saved trips
- Search mismatch

### 21.13 Loading Skeleton Component

#### Component Name
- `State / Skeleton`

#### Variants
- `Card`
- `Sidebar`
- `Accordion`
- `Text Row`

#### Visual Spec
- Base fill: `rgba(255,255,255,0.06)`
- Highlight shimmer: `rgba(255,255,255,0.12)`
- Radius follows target component

### 21.14 Icon Rules

#### Icon System
- Stroke style đồng nhất, rounded ends
- Base sizes:
  - `16`
  - `20`
  - `24`

#### Usage
- Leading icons chỉ dùng khi tăng tốc scan
- Không đặt quá 1 leading và 1 trailing icon trong cùng button
- Badge icon giữ size `12` hoặc `14`

### 21.15 Component Spacing Rules
- Button inside card cách price block: `16`
- Card-to-card desktop gap: `24`
- Card-to-card mobile gap: `16`
- Section gap large: `32`
- Section gap medium: `24`
- Label-to-value gap in KPI: `4`

### 21.16 Component Accessibility Rules
- Text button tối thiểu `14px`
- Icon-only interactive item phải có frame tối thiểu `44 x 44`
- Focus ring cho interactive components:
  - `0 0 0 4 rgba(214,179,106,0.16)`
- Disabled state phải giảm opacity nhưng vẫn đọc được nhãn

### 21.17 Figma Variant Matrix To Build
- `Button`: hierarchy x size x state x icon
- `Input`: type x state
- `Chip`: type x state
- `Badge`: semantic x emphasis
- `Card / Itinerary`: state x emphasis
- `Accordion`: type x state
- `Sidebar / Booking Summary`: detail x booking

### 21.18 Build Order Recommendation
1. Foundations: color, type, effect, spacing styles
2. Atoms: button, input, chip, badge, icon
3. Molecules: KPI item, review snippet, price row
4. Organisms: itinerary card, hotel card, accordion, sidebar
5. Screens: Home, Results, Detail, Booking, Success
