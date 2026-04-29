import 'package:flutter/material.dart';
import '../widgets/fab_world_scene.dart';

class FabHomeScreen extends StatelessWidget {
  const FabHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080118),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              FabWorldScene(height: 260),
              _buildMetricCards(),
              _buildZoneCards(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16,12,16,8),
      child: Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal:10,vertical:5),
          decoration: BoxDecoration(gradient: const LinearGradient(colors:[Color(0xFF7C3AED),Color(0xFFDB2777)]),borderRadius: BorderRadius.circular(8)),
          child: const Text('NOVA',style: TextStyle(color:Colors.white,fontWeight:FontWeight.w800,fontSize:13,letterSpacing:1.5))),
        const SizedBox(width:8),
        const Text('Fabulously Me',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w700,fontSize:16)),
        const Spacer(),
        Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
          decoration:BoxDecoration(color:const Color(0xFFDB2777).withOpacity(0.15),border:Border.all(color:const Color(0xFFDB2777).withOpacity(0.4)),borderRadius:BorderRadius.circular(20)),
          child:const Text('✨ Feeling Fab',style:TextStyle(color:Color(0xFFEC4899),fontSize:10,fontWeight:FontWeight.w600))),
      ]),
    );
  }

  Widget _buildMetricCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16,12,16,0),
      child: Row(children: [
        Expanded(child: _metricCard('😊','Mood','7.2',const Color(0xFF8B5CF6))),
        const SizedBox(width:8),
        Expanded(child: _metricCard('🩺','Pain','4.1',const Color(0xFFEC4899))),
        const SizedBox(width:8),
        Expanded(child: _metricCard('⚡','Energy','6.8',const Color(0xFFF59E0B))),
      ]),
    );
  }

  Widget _metricCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF130535),border: Border.all(color:color.withOpacity(0.25)),borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[Text(emoji,style:const TextStyle(fontSize:12)),const SizedBox(width:4),Text(label,style:TextStyle(color:color,fontSize:10,fontWeight:FontWeight.w600))]),
        const SizedBox(height:4),
        Text(value,style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w800)),
      ]),
    );
  }

  Widget _buildZoneCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),
        crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:1.5,
        children:const [
          _ZoneCard(emoji:'🌊',name:'Calm Lagoon',color:Color(0xFF0EA5E9)),
          _ZoneCard(emoji:'🦕',name:'Dino Garden',color:Color(0xFF22C55E)),
          _ZoneCard(emoji:'🌙',name:'Sleep Nest',color:Color(0xFF8B5CF6)),
          _ZoneCard(emoji:'🛡️',name:'Safe Corner',color:Color(0xFFEC4899)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height:60,
      decoration:const BoxDecoration(color:Color(0xFF0D0228),border:Border(top:BorderSide(color:Color(0xFF2D1060),width:0.5))),
      child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:const [
        _NavItem(icon:'🏠',label:'Home',active:true),
        _NavItem(icon:'✅',label:'Check-In'),
        _NavItem(icon:'➕',label:'',isCenter:true),
        _NavItem(icon:'💡',label:'Insights'),
        _NavItem(icon:'👩‍⚕️',label:'Clinician'),
      ]),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final String emoji,name;
  final Color color;
  const _ZoneCard({required this.emoji,required this.name,required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:const EdgeInsets.all(12),
      decoration:BoxDecoration(color:const Color(0xFF130535),border:Border.all(color:color.withOpacity(0.3)),borderRadius:BorderRadius.circular(12)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(emoji,style:const TextStyle(fontSize:22)),
        const SizedBox(height:4),
        Text(name,style:const TextStyle(color:Colors.white,fontSize:12,fontWeight:FontWeight.w700)),
        const Spacer(),
        Text('Enter Zone →',style:TextStyle(color:color,fontSize:9,fontWeight:FontWeight.w600)),
      ]),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon,label;
  final bool active,isCenter;
  const _NavItem({required this.icon,required this.label,this.active=false,this.isCenter=false});
  @override
  Widget build(BuildContext context) {
    if(isCenter) return Container(width:44,height:44,decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFF7C3AED),Color(0xFFDB2777)]),shape:BoxShape.circle),child:const Center(child:Text('➕',style:TextStyle(fontSize:18))));
    return Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      Text(icon,style:const TextStyle(fontSize:16)),
      const SizedBox(height:2),
      Text(label,style:TextStyle(color:active?const Color(0xFF8B5CF6):const Color(0xFF6B7280),fontSize:9)),
    ]);
  }
}
