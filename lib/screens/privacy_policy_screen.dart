import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/flowcash_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: FlowCashTokens.bgDark,
      appBar: AppBar(
        backgroundColor: FlowCashTokens.bgDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Aviso de Privacidad',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FlowCashTokens.textDark,
          ),
        ),
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: FlowCashTokens.textDark),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: FlowCashTokens.borderDark),
        ),
      ),
      body: AmbientGradient(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _PolicyHeader(),
                  SizedBox(height: 32),
                  _Section(
                    number: 'I',
                    title: 'Identidad y domicilio del Responsable',
                    body: _IdentidadBody(),
                  ),
                  _Section(
                    number: 'II',
                    title: 'Datos personales que se recaban',
                    body: _DatosBody(),
                  ),
                  _Section(
                    number: 'III',
                    title: 'Finalidades del tratamiento',
                    body: _FinalidadesBody(),
                  ),
                  _Section(
                    number: 'IV',
                    title: 'Transferencia de datos personales',
                    body: _TransferenciasBody(),
                  ),
                  _Section(
                    number: 'V',
                    title: 'Derechos ARCO',
                    body: _ArcoBody(),
                  ),
                  _Section(
                    number: 'VI',
                    title: 'Mecanismos para limitar el uso o divulgación',
                    body: _LimitacionBody(),
                  ),
                  _Section(
                    number: 'VII',
                    title: 'Uso de cookies y tecnologías de rastreo',
                    body: _CookiesBody(),
                  ),
                  _Section(
                    number: 'VIII',
                    title: 'Cambios al Aviso de Privacidad',
                    body: _CambiosBody(),
                  ),
                  _Section(
                    number: 'IX',
                    title: 'Consentimiento',
                    body: _ConsentimientoBody(),
                  ),
                  SizedBox(height: 16),
                  _PolicyFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _PolicyHeader extends StatelessWidget {
  const _PolicyHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FlowCashLogoMark(size: 40),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FlowCashTokens.indigo, FlowCashTokens.teal],
          ).createShader(bounds),
          child: const Text(
            'Aviso de Privacidad Integral',
            style: TextStyle(
              fontFamily: 'Space Grotesk',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'FlowCash — Aplicación de control de gastos personales',
          style: TextStyle(
            fontSize: 13,
            color: FlowCashTokens.textDarkMuted,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Última actualización: mayo de 2026',
          style: TextStyle(
            fontSize: 12,
            color: FlowCashTokens.textDarkDim,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: FlowCashTokens.indigo.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FlowCashTokens.indigo.withOpacity(0.25)),
          ),
          child: const Text(
            'El presente Aviso de Privacidad se emite en cumplimiento a la Ley Federal de '
            'Protección de Datos Personales en Posesión de los Particulares (LFPDPPP), '
            'publicada en el Diario Oficial de la Federación el 5 de julio de 2010, así como '
            'su Reglamento y los Lineamientos del Aviso de Privacidad emitidos por el '
            'Instituto Nacional de Transparencia, Acceso a la Información y Protección de '
            'Datos Personales (INAI).',
            style: TextStyle(
              fontSize: 13,
              color: FlowCashTokens.textDarkMuted,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section wrapper
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final Widget body;

  const _Section({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [FlowCashTokens.indigo, FlowCashTokens.teal],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: FlowCashTokens.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlowCashTokens.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FlowCashTokens.borderDark),
            ),
            child: body,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body widgets per section
// ---------------------------------------------------------------------------

class _IdentidadBody extends StatelessWidget {
  const _IdentidadBody();

  @override
  Widget build(BuildContext context) {
    return const _BodyText(
      'FlowCash es un servicio operado por David Hernández Hernández '
      '(en lo sucesivo "el Responsable"), con domicilio en la Ciudad de México, '
      'México. Para cualquier consulta relacionada con el tratamiento de sus datos '
      'personales, puede contactarnos a través del correo electrónico: '
      'flowcash@flowcash.cloud\n\n'
      'El Responsable es quien decide sobre el tratamiento de sus datos personales '
      'conforme a lo establecido en la LFPDPPP.',
    );
  }
}

class _DatosBody extends StatelessWidget {
  const _DatosBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BodyText(
            'Para la prestación del servicio, FlowCash recaba las siguientes '
            'categorías de datos personales:'),
        SizedBox(height: 12),
        _SubHeading('Datos de identificación y contacto'),
        _BulletList([
          'Nombre completo',
          'Apellido paterno',
          'Correo electrónico',
          'Edad',
        ]),
        SizedBox(height: 10),
        _SubHeading('Datos financieros'),
        _BulletList([
          'Montos de gastos e ingresos registrados',
          'Categorías de transacciones',
          'Descripciones de movimientos',
          'Fechas y monedas de las transacciones',
        ]),
        SizedBox(height: 10),
        _SubHeading('Datos de autenticación'),
        _BulletList([
          'Contraseña (almacenada con hash bcrypt; nunca en texto claro)',
          'Tokens de acceso y renovación (JWT)',
          'Identificador de cuenta Google (cuando se usa Google OAuth)',
        ]),
        SizedBox(height: 10),
        _SubHeading('Datos técnicos'),
        _BulletList([
          'Dirección IP',
          'Tipo de dispositivo y sistema operativo',
          'Registros de acceso (logs)',
        ]),
        SizedBox(height: 10),
        _BodyText(
          'FlowCash NO recaba datos personales sensibles en los términos del '
          'artículo 3, fracción VI de la LFPDPPP (como datos de salud, '
          'biométricos, o de vida sexual).',
        ),
      ],
    );
  }
}

class _FinalidadesBody extends StatelessWidget {
  const _FinalidadesBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubHeading('Finalidades primarias (necesarias para el servicio)'),
        _BulletList([
          'Crear y administrar su cuenta de usuario.',
          'Autenticar su identidad en cada inicio de sesión.',
          'Registrar, almacenar y mostrar sus gastos e ingresos personales.',
          'Generar reportes y estadísticas de sus movimientos financieros.',
          'Enviar correos transaccionales (verificación de cuenta, recuperación '
              'de contraseña).',
          'Dar cumplimiento a obligaciones legales aplicables.',
        ]),
        SizedBox(height: 12),
        _SubHeading(
            'Finalidades secundarias (requieren su consentimiento expreso)'),
        _BulletList([
          'Enviar comunicaciones sobre nuevas funcionalidades o actualizaciones '
              'de FlowCash.',
          'Realizar análisis estadísticos agregados y anónimos para mejorar '
              'la experiencia de uso.',
        ]),
        SizedBox(height: 10),
        _BodyText(
          'Si no desea que sus datos sean tratados para las finalidades secundarias, '
          'puede manifestar su negativa en cualquier momento enviando un correo a '
          'privacidad@flowcash.app con el asunto "Opt-out finalidades secundarias".',
        ),
      ],
    );
  }
}

class _TransferenciasBody extends StatelessWidget {
  const _TransferenciasBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BodyText(
          'FlowCash podrá transferir sus datos personales a terceros sin requerir '
          'su consentimiento en los siguientes supuestos previstos en el artículo '
          '37 de la LFPDPPP:',
        ),
        SizedBox(height: 10),
        _BulletList([
          'Autoridades competentes, cuando sea requerido por mandato judicial '
              'o disposición legal.',
          'Encargados del tratamiento (proveedores de infraestructura en la nube) '
              'que actúen exclusivamente bajo las instrucciones del Responsable y '
              'estén sujetos a obligaciones equivalentes de confidencialidad.',
        ]),
        SizedBox(height: 10),
        _BodyText(
          'FlowCash NO vende, cede ni comercializa sus datos personales a terceros '
          'con fines publicitarios o de mercadotecnia. Los proveedores de '
          'infraestructura (p. ej. servicios de cómputo en la nube) tratan los '
          'datos únicamente como encargados y bajo acuerdos de confidencialidad.',
        ),
        SizedBox(height: 10),
        _SubHeading('Google OAuth'),
        _BodyText(
          'Cuando el titular opta por autenticarse mediante Google, FlowCash recibe '
          'únicamente el token de identidad emitido por Google. La información de la '
          'cuenta Google se rige por las Políticas de Privacidad de Google '
          '(policies.google.com/privacy). FlowCash no tiene acceso a su contraseña '
          'de Google ni a ningún dato adicional de su cuenta.',
        ),
      ],
    );
  }
}

class _ArcoBody extends StatelessWidget {
  const _ArcoBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BodyText(
          'En términos del artículo 22 de la LFPDPPP, usted tiene derecho a:',
        ),
        SizedBox(height: 10),
        _BulletList([
          'Acceso: conocer qué datos personales tenemos de usted, cómo los '
              'tratamos y para qué finalidades.',
          'Rectificación: solicitar la corrección de datos inexactos o '
              'incompletos.',
          'Cancelación: pedir la supresión de sus datos cuando considere que '
              'no son necesarios para las finalidades que justificaron su obtención.',
          'Oposición: oponerse al tratamiento de sus datos para finalidades '
              'específicas.',
        ]),
        SizedBox(height: 12),
        _SubHeading('Procedimiento para ejercer derechos ARCO'),
        _BulletList([
          'Envíe su solicitud al correo: privacidad@flowcash.app',
          'Asunto del correo: "Solicitud ARCO"',
          'Incluya: nombre completo, correo de la cuenta registrada, descripción '
              'del derecho que desea ejercer y copia de identificación oficial.',
          'El Responsable responderá en un plazo máximo de 20 días hábiles '
              'a partir de la recepción de la solicitud.',
          'La respuesta se comunicará por el mismo medio en que fue enviada '
              'la solicitud.',
        ]),
        SizedBox(height: 10),
        _BodyText(
          'En caso de que su solicitud resulte procedente, los cambios se harán '
          'efectivos dentro de los 15 días hábiles siguientes a la comunicación '
          'de la respuesta. Puede presentar su queja o denuncia ante el INAI '
          '(www.inai.org.mx) si considera que el Responsable no ha atendido '
          'correctamente su solicitud.',
        ),
      ],
    );
  }
}

class _LimitacionBody extends StatelessWidget {
  const _LimitacionBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BodyText(
          'Para limitar el uso o divulgación de sus datos personales, usted puede:',
        ),
        SizedBox(height: 10),
        _BulletList([
          'Eliminar su cuenta desde la sección "Configuración > Cuenta > '
              'Eliminar cuenta" dentro de la aplicación, lo que provocará la '
              'supresión de sus datos personales de nuestros sistemas activos.',
          'Enviar un correo a privacidad@flowcash.app solicitando la restricción '
              'del tratamiento para finalidades secundarias.',
          'Inscribirse en el Registro Público de Consumidores (REPCO) para '
              'bloquear el envío de comunicaciones comerciales no deseadas.',
        ]),
        SizedBox(height: 10),
        _BodyText(
          'Los datos financieros que usted registra en FlowCash son de uso '
          'exclusivo para la prestación del servicio y no son compartidos con '
          'instituciones financieras ni terceros con fines comerciales.',
        ),
      ],
    );
  }
}

class _CookiesBody extends StatelessWidget {
  const _CookiesBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BodyText(
          'La versión web de FlowCash puede utilizar almacenamiento local '
          '(localStorage) y cookies de sesión con las siguientes finalidades:',
        ),
        SizedBox(height: 10),
        _BulletList([
          'Mantener la sesión activa del usuario (cookies de autenticación).',
          'Recordar preferencias de interfaz (tema, moneda por defecto).',
        ]),
        SizedBox(height: 10),
        _BodyText(
          'FlowCash no utiliza cookies de rastreo publicitario ni comparte '
          'datos de navegación con redes de publicidad. Puede gestionar las '
          'cookies desde la configuración de su navegador; sin embargo, '
          'deshabilitar las cookies de sesión impedirá el funcionamiento '
          'correcto de la aplicación.',
        ),
      ],
    );
  }
}

class _CambiosBody extends StatelessWidget {
  const _CambiosBody();

  @override
  Widget build(BuildContext context) {
    return const _BodyText(
      'El Responsable se reserva el derecho de modificar el presente Aviso de '
      'Privacidad en cualquier momento para adaptarlo a cambios legislativos, '
      'jurisprudenciales, o de negocio. Cualquier modificación será notificada '
      'a través de:\n\n'
      '  • Un aviso visible en la pantalla de inicio de sesión de FlowCash, y/o\n'
      '  • Un correo electrónico enviado a la dirección registrada en su cuenta.\n\n'
      'La versión vigente siempre estará disponible en esta sección de la '
      'aplicación y en flowcash.app/privacidad. Si continúa utilizando el '
      'servicio después de la notificación de cambios, se entenderá que acepta '
      'las modificaciones realizadas.',
    );
  }
}

class _ConsentimientoBody extends StatelessWidget {
  const _ConsentimientoBody();

  @override
  Widget build(BuildContext context) {
    return const _BodyText(
      'Al crear una cuenta en FlowCash mediante el formulario de registro y '
      'marcar la casilla "Acepto los Términos de Servicio y la Política de '
      'Privacidad", usted manifiesta su consentimiento expreso e informado para '
      'el tratamiento de sus datos personales conforme a las finalidades '
      'primarias descritas en el presente Aviso.\n\n'
      'Para las finalidades secundarias, el consentimiento se obtendrá de '
      'manera diferenciada y podrá ser revocado en cualquier momento sin efectos '
      'retroactivos, conforme al artículo 8 de la LFPDPPP.',
    );
  }
}

// ---------------------------------------------------------------------------
// Footer
// ---------------------------------------------------------------------------

class _PolicyFooter extends StatelessWidget {
  const _PolicyFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlowCashTokens.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlowCashTokens.borderDark),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fundamento legal',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: FlowCashTokens.textDark,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '• Ley Federal de Protección de Datos Personales en Posesión de los '
            'Particulares (DOF 05-jul-2010)\n'
            '• Reglamento de la LFPDPPP (DOF 21-dic-2011)\n'
            '• Lineamientos del Aviso de Privacidad (DOF 17-ene-2013)\n'
            '• Autoridad supervisora: INAI — www.inai.org.mx',
            style: TextStyle(
              fontSize: 12,
              color: FlowCashTokens.textDarkDim,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable text primitives
// ---------------------------------------------------------------------------

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        color: FlowCashTokens.textDarkMuted,
        height: 1.65,
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  final String text;
  const _SubHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: FlowCashTokens.textDark,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList(this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5, right: 8),
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: FlowCashTokens.teal,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: FlowCashTokens.textDarkMuted,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
